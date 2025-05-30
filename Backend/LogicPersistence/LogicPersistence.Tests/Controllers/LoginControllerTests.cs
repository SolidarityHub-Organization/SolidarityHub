using System;
using System.Threading.Tasks;
using LogicPersistence.Api.Controllers;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace LogicPersistence.Tests.Controllers
{
    public class LoginControllerTests
    {
        private readonly Mock<ILoginServices> _mockLoginServices;
        private readonly LoginController _controller;

        public LoginControllerTests()
        {
            _mockLoginServices = new Mock<ILoginServices>();
            _controller = new LoginController(_mockLoginServices.Object);
        }

        [Fact]
        public async Task LogInAsync_WithValidCredentials_ReturnsOkResult()
        {
            // Arrange
            var loginDto = new LoginDto
            {
                email = "test@test.com",
                password = "password123"
            };
            var expectedResponse = "{\"role\":\"victima\",\"id\":1,\"name\":\"Test User\"}";

            _mockLoginServices.Setup(service => service.LogInAsync(loginDto.email, loginDto.password))
                .ReturnsAsync(expectedResponse);

            // Act
            var result = await _controller.LogInAsync(loginDto);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.Equal(expectedResponse, okResult.Value);
        }

        [Fact]
        public async Task LogInAsync_WithInvalidCredentials_ReturnsUnauthorized()
        {
            // Arrange
            var loginDto = new LoginDto
            {
                email = "test@test.com",
                password = "wrongpassword"
            };

            _mockLoginServices.Setup(service => service.LogInAsync(loginDto.email, loginDto.password))
                .ReturnsAsync((string)null);

            // Act
            var result = await _controller.LogInAsync(loginDto);

            // Assert
            Assert.IsType<UnauthorizedObjectResult>(result);
        }

        [Fact]
        public async Task LogInAsync_WhenServiceThrowsKeyNotFoundException_ReturnsNotFound()
        {
            // Arrange
            var loginDto = new LoginDto
            {
                email = "nonexistent@test.com",
                password = "password123"
            };

            _mockLoginServices.Setup(service => service.LogInAsync(loginDto.email, loginDto.password))
                .ThrowsAsync(new KeyNotFoundException("User not found"));

            // Act
            var result = await _controller.LogInAsync(loginDto);

            // Assert
            var notFoundResult = Assert.IsType<NotFoundObjectResult>(result);
            Assert.Equal("User not found", notFoundResult.Value);
        }

        [Fact]
        public async Task LogInAsync_WhenServiceThrowsException_ReturnsInternalServerError()
        {
            // Arrange
            var loginDto = new LoginDto
            {
                email = "test@test.com",
                password = "password123"
            };

            _mockLoginServices.Setup(service => service.LogInAsync(loginDto.email, loginDto.password))
                .ThrowsAsync(new Exception("Internal server error"));

            // Act
            var result = await _controller.LogInAsync(loginDto);

            // Assert
            var statusCodeResult = Assert.IsType<ObjectResult>(result);
            Assert.Equal(500, statusCodeResult.StatusCode);
            Assert.Equal("Internal server error", statusCodeResult.Value);
        }
    }
} 