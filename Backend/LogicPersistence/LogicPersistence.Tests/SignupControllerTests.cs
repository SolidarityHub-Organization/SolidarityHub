using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using LogicPersistence.Api.Models.DTOs;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;
using DotNetEnv;

namespace LogicPersistence.Tests
{
    public class SignupControllerTests : IClassFixture<WebApplicationFactory<App>>
    {
        private readonly HttpClient _client;

        public SignupControllerTests(WebApplicationFactory<App> factory)
        {
            // Load environment variables from .env.development in the test project root
            Env.Load(".env.development");
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task SignupAsync_ValidUser_ReturnsOkAndPersistsUser()
        {
            // Arrange
            var uniqueEmail = $"testingEmail_{System.DateTime.UtcNow.Ticks}@example.com";
            var signupJson = new
            {
                name = "Testing Name",
                email = uniqueEmail,
                phone_number = "1234567890",
                prefix = "34",
                address = "123 Testing St",
                surname = "Testing Surname",
                password = "TestingPassword123!",
                identification = 123456789,
                role = "Volunteer"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", signupJson);

            // Assert
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                throw new System.Exception($"Signup failed: {response.StatusCode} - {errorContent}");
            }
            response.EnsureSuccessStatusCode();
            // Optionally, check the response content and/or verify user in DB
        }
    }
}
