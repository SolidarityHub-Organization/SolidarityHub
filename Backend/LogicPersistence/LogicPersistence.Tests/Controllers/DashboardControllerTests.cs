using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LogicPersistence.Api.Controllers;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace LogicPersistence.Tests.Controllers
{
    public class DashboardControllerTests
    {
        private readonly Mock<IDashboardServices> _mockDashboardServices;
        private readonly DashboardController _controller;

        public DashboardControllerTests()
        {
            _mockDashboardServices = new Mock<IDashboardServices>();
            _controller = new DashboardController(_mockDashboardServices.Object);
        }

        [Fact]
        public async Task GetActivityLogData_WithValidDateRange_ReturnsOkResult()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;
            var expectedActivities = new List<ActivityLogDto>
            {
                new ActivityLogDto
                {
                    id = 1,
                    name = "Test User 1",
                    type = "Víctima",
                    date = DateTime.Now.AddDays(-5)
                },
                new ActivityLogDto
                {
                    id = 2,
                    name = "Test User 2",
                    type = "Voluntario",
                    date = DateTime.Now.AddDays(-3)
                }
            };

            _mockDashboardServices.Setup(service => service.GetActivityLogDataAsync(fromDate, toDate))
                .ReturnsAsync(expectedActivities);

            // Act
            var result = await _controller.GetActivityLogData(fromDate, toDate);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var activities = Assert.IsAssignableFrom<IEnumerable<ActivityLogDto>>(okResult.Value);
            Assert.Equal(expectedActivities, activities);
        }

        [Fact]
        public async Task GetActivityLogData_WhenServiceThrowsInvalidOperation_ReturnsInternalServerError()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;

            _mockDashboardServices.Setup(service => service.GetActivityLogDataAsync(fromDate, toDate))
                .ThrowsAsync(new InvalidOperationException("Test error"));

            // Act
            var result = await _controller.GetActivityLogData(fromDate, toDate);

            // Assert
            var statusCodeResult = Assert.IsType<ObjectResult>(result);
            Assert.Equal(500, statusCodeResult.StatusCode);
            Assert.Equal("Test error", statusCodeResult.Value);
        }

        [Fact]
        public async Task GetActivityLogData_WhenServiceThrowsException_ReturnsInternalServerError()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;

            _mockDashboardServices.Setup(service => service.GetActivityLogDataAsync(fromDate, toDate))
                .ThrowsAsync(new Exception("Unexpected error"));

            // Act
            var result = await _controller.GetActivityLogData(fromDate, toDate);

            // Assert
            var statusCodeResult = Assert.IsType<ObjectResult>(result);
            Assert.Equal(500, statusCodeResult.StatusCode);
            Assert.Equal("Unexpected error", statusCodeResult.Value);
        }

        [Fact]
        public async Task GetActivityLogData_WithEmptyResult_ReturnsOkWithEmptyList()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;
            var emptyList = new List<ActivityLogDto>();

            _mockDashboardServices.Setup(service => service.GetActivityLogDataAsync(fromDate, toDate))
                .ReturnsAsync(emptyList);

            // Act
            var result = await _controller.GetActivityLogData(fromDate, toDate);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var activities = Assert.IsAssignableFrom<IEnumerable<ActivityLogDto>>(okResult.Value);
            Assert.Empty(activities);
        }
    }
} 