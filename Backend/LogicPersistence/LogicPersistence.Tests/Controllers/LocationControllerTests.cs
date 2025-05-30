using LogicPersistence.Api.Controllers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;
using TaskAsync = System.Threading.Tasks.Task;

namespace LogicPersistence.Tests.Controllers
{
    public class LocationControllerTests
    {
        private readonly Mock<ILocationServices> _mockLocationServices;
        private readonly LocationController _controller;

        public LocationControllerTests()
        {
            _mockLocationServices = new Mock<ILocationServices>();
            _controller = new LocationController(_mockLocationServices.Object);
        }

        [Fact]
        public async TaskAsync CreateLocationAsync_ReturnsCreatedAtRoute_WhenServiceSucceeds()
        {
            // Arrange
            var locationCreateDto = new LocationCreateDto
            {
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            var expectedLocation = new Location
            {
                id = 1,
                latitude = locationCreateDto.latitude,
                longitude = locationCreateDto.longitude,
                victim_id = locationCreateDto.victim_id
            };

            _mockLocationServices.Setup(s => s.CreateLocationAsync(locationCreateDto))
                .ReturnsAsync(expectedLocation);

            // Act
            var result = await _controller.CreateLocationAsync(locationCreateDto);

            // Assert
            var createdAtRouteResult = Assert.IsType<CreatedAtRouteResult>(result);
            Assert.Equal("GetLocationById", createdAtRouteResult.RouteName);
            var location = Assert.IsType<Location>(createdAtRouteResult.Value);
            Assert.Equal(expectedLocation.id, location.id);
        }

        [Fact]
        public async TaskAsync GetLocationByIdAsync_ReturnsOkResult_WhenLocationExists()
        {
            // Arrange
            var expectedLocation = new Location
            {
                id = 1,
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            _mockLocationServices.Setup(s => s.GetLocationByIdAsync(1))
                .ReturnsAsync(expectedLocation);

            // Act
            var result = await _controller.GetLocationByIdAsync(1);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var location = Assert.IsType<Location>(okResult.Value);
            Assert.Equal(expectedLocation.id, location.id);
        }

        [Fact]
        public async TaskAsync GetLocationByIdAsync_ReturnsNotFound_WhenLocationDoesNotExist()
        {
            // Arrange
            _mockLocationServices.Setup(s => s.GetLocationByIdAsync(1))
                .ThrowsAsync(new KeyNotFoundException("Location not found"));

            // Act
            var result = await _controller.GetLocationByIdAsync(1);

            // Assert
            Assert.IsType<NotFoundObjectResult>(result);
        }

        [Fact]
        public async TaskAsync UpdateLocationAsync_ReturnsOkResult_WhenUpdateSucceeds()
        {
            // Arrange
            var locationUpdateDto = new LocationUpdateDto
            {
                id = 1,
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            var expectedLocation = new Location
            {
                id = locationUpdateDto.id,
                latitude = locationUpdateDto.latitude,
                longitude = locationUpdateDto.longitude,
                victim_id = locationUpdateDto.victim_id
            };

            _mockLocationServices.Setup(s => s.UpdateLocationAsync(1, locationUpdateDto))
                .ReturnsAsync(expectedLocation);

            // Act
            var result = await _controller.UpdateLocationAsync(1, locationUpdateDto);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var location = Assert.IsType<Location>(okResult.Value);
            Assert.Equal(expectedLocation.id, location.id);
        }

        [Fact]
        public async TaskAsync DeleteLocationAsync_ReturnsNoContent_WhenDeleteSucceeds()
        {
            // Arrange
            _mockLocationServices.Setup(s => s.DeleteLocationAsync(1))
                .Returns(TaskAsync.CompletedTask);

            // Act
            var result = await _controller.DeleteLocationAsync(1);

            // Assert
            Assert.IsType<NoContentResult>(result);
        }

        [Fact]
        public async TaskAsync GetAllLocationsAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedLocations = new List<Location>
            {
                new Location
                {
                    id = 1,
                    latitude = 39.4699,
                    longitude = -0.3763,
                    victim_id = 1
                }
            };

            _mockLocationServices.Setup(s => s.GetAllLocationsAsync())
                .ReturnsAsync(expectedLocations);

            // Act
            var result = await _controller.GetAllLocationsAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var locations = Assert.IsAssignableFrom<IEnumerable<Location>>(okResult.Value);
            Assert.Equal(expectedLocations.Count(), locations.Count());
        }

        [Fact]
        public async TaskAsync GetPlacesByLocationIdAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedPlaces = new List<AffectedZone>
            {
                new AffectedZone
                {
                    id = 1,
                    name = "Test Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.High
                }
            };

            _mockLocationServices.Setup(s => s.GetAffectedZoneByLocationIdAsync(1))
                .ReturnsAsync(expectedPlaces);

            // Act
            var result = await _controller.GetPlacesByLocationIdAsync(1);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var places = Assert.IsAssignableFrom<IEnumerable<AffectedZone>>(okResult.Value);
            Assert.Equal(expectedPlaces.Count(), places.Count());
        }

        [Fact]
        public async TaskAsync GetPaginatedLocationsAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedLocations = new List<Location>
            {
                new Location
                {
                    id = 1,
                    latitude = 39.4699,
                    longitude = -0.3763
                }
            };

            var paginationResult = (Locations: expectedLocations, TotalCount: 1);

            _mockLocationServices.Setup(s => s.GetPaginatedLocationsAsync(1, 10))
                .ReturnsAsync(paginationResult);

            // Act
            var result = await _controller.GetPaginatedLocationsAsync(1, 10);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var paginatedResult = Assert.IsType<PaginatedResultDto<Location>>(okResult.Value);
            var items = paginatedResult.Items;
            Assert.Single(items);
            Assert.Equal(1, paginatedResult.TotalCount);
            Assert.Equal(1, paginatedResult.PageNumber);
            Assert.Equal(10, paginatedResult.PageSize);
            Assert.Equal(1, paginatedResult.TotalPages);
        }
    }
} 