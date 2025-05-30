using System;
using System.Threading.Tasks;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Services;
using Moq;
using Xunit;

namespace LogicPersistence.Tests.Services
{
    public class LoginServicesTests
    {
        private readonly Mock<IVictimRepository> _mockVictimRepository;
        private readonly Mock<IVolunteerRepository> _mockVolunteerRepository;
        private readonly LoginServices _loginServices;

        public LoginServicesTests()
        {
            _mockVictimRepository = new Mock<IVictimRepository>();
            _mockVolunteerRepository = new Mock<IVolunteerRepository>();
            _loginServices = new LoginServices(_mockVictimRepository.Object, _mockVolunteerRepository.Object);
        }

        [Fact]
        public async System.Threading.Tasks.Task LogInAsync_WithValidVictimCredentials_ReturnsVictimRole()
        {
            // Arrange
            var testEmail = "victim@test.com";
            var testPassword = "password123";
            var testVictim = new Victim
            {
                id = 1,
                email = testEmail,
                password = testPassword,
                name = "Test Victim"
            };

            _mockVictimRepository.Setup(repo => repo.GetVictimByEmailAsync(testEmail))
                .ReturnsAsync(testVictim);

            // Act
            var result = await _loginServices.LogInAsync(testEmail, testPassword);

            // Assert
            Assert.NotNull(result);
            Assert.Contains("victima", result);
            Assert.Contains(testVictim.id.ToString(), result);
            Assert.Contains(testVictim.name, result);
        }

        [Fact]
        public async System.Threading.Tasks.Task LogInAsync_WithValidVolunteerCredentials_ReturnsVolunteerRole()
        {
            // Arrange
            var testEmail = "volunteer@test.com";
            var testPassword = "password123";
            var testVolunteer = new Volunteer
            {
                id = 1,
                email = testEmail,
                password = testPassword,
                name = "Test Volunteer",
                phone_number = "123456789",
                prefix = 34
            };

            _mockVictimRepository.Setup(repo => repo.GetVictimByEmailAsync(testEmail))
                .ReturnsAsync((Victim)null);
            _mockVolunteerRepository.Setup(repo => repo.GetVolunteerByEmailAsync(testEmail))
                .ReturnsAsync(testVolunteer);

            // Act
            var result = await _loginServices.LogInAsync(testEmail, testPassword);

            // Assert
            Assert.NotNull(result);
            Assert.Contains("voluntario", result);
            Assert.Contains(testVolunteer.id.ToString(), result);
            Assert.Contains(testVolunteer.name, result);
        }

        [Fact]
        public async System.Threading.Tasks.Task LogInAsync_WithInvalidPassword_ReturnsPasswordIncorrect()
        {
            // Arrange
            var testEmail = "test@test.com";
            var testPassword = "wrongpassword";
            var testVictim = new Victim
            {
                id = 1,
                email = testEmail,
                password = "correctpassword",
                name = "Test User"
            };

            _mockVictimRepository.Setup(repo => repo.GetVictimByEmailAsync(testEmail))
                .ReturnsAsync(testVictim);

            // Act
            var result = await _loginServices.LogInAsync(testEmail, testPassword);

            // Assert
            Assert.NotNull(result);
            Assert.Contains("password incorrect", result);
        }

        [Fact]
        public async System.Threading.Tasks.Task LogInAsync_WithNonExistentEmail_ReturnsExists()
        {
            // Arrange
            var testEmail = "nonexistent@test.com";
            var testPassword = "password123";

            _mockVictimRepository.Setup(repo => repo.GetVictimByEmailAsync(testEmail))
                .ReturnsAsync((Victim)null);
            _mockVolunteerRepository.Setup(repo => repo.GetVolunteerByEmailAsync(testEmail))
                .ReturnsAsync((Volunteer)null);

            // Act
            var result = await _loginServices.LogInAsync(testEmail, testPassword);

            // Assert
            Assert.NotNull(result);
            Assert.Contains("exists", result);
        }
    }
} 