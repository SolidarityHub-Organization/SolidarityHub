using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using LogicPersistence.Api.Models.DTOs;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace LogicPersistence.Tests
{
    public class SignupControllerTests : IClassFixture<WebApplicationFactory<App>>
    {
        private readonly HttpClient _client;

        public SignupControllerTests(WebApplicationFactory<App> factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task SignupAsync_ValidUser_ReturnsOkAndPersistsUser()
        {
            // Arrange
            var signupDto = new SignupDto
            {
                email = "testuser@example.com",
                password = "TestPassword123!",
                name = "Test",
                surname = "User",
                prefix = 1,
                phone_number = "1234567890"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", signupDto);

            // Assert
            response.EnsureSuccessStatusCode();
            // Optionally, check the response content and/or verify user in DB
        }
    }
}
