using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;
using LogicPersistence.Api.Services.Interfaces;
using Moq;
using Xunit;
using TaskAsync = System.Threading.Tasks.Task;

namespace LogicPersistence.Tests.Services
{
    public class LocationServicesTests
    {
        private readonly Mock<ILocationRepository> _mockLocationRepository;
        private readonly Mock<IPaginationService> _mockPaginationService;
        private readonly LocationServices _service;

        public LocationServicesTests()
        {
            _mockLocationRepository = new Mock<ILocationRepository>();
            _mockPaginationService = new Mock<IPaginationService>();
            _service = new LocationServices(_mockLocationRepository.Object, _mockPaginationService.Object);
        }

        [Fact]
        public async TaskAsync CreateLocationAsync_ReturnsLocation_WhenCreateSucceeds()
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

            _mockLocationRepository.Setup(r => r.CreateLocationAsync(It.IsAny<Location>()))
                .ReturnsAsync(expectedLocation);

            // Act
            var result = await _service.CreateLocationAsync(locationCreateDto);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(expectedLocation.id, result.id);
            Assert.Equal(expectedLocation.latitude, result.latitude);
            Assert.Equal(expectedLocation.longitude, result.longitude);
            Assert.Equal(expectedLocation.victim_id, result.victim_id);
        }

        [Fact]
        public async TaskAsync CreateLocationAsync_ThrowsArgumentNullException_WhenDtoIsNull()
        {
            // Act & Assert
            await Assert.ThrowsAsync<ArgumentNullException>(() => _service.CreateLocationAsync(null));
        }

        [Fact]
        public async TaskAsync GetLocationByIdAsync_ReturnsLocation_WhenLocationExists()
        {
            // Arrange
            var expectedLocation = new Location
            {
                id = 1,
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(expectedLocation);

            // Act
            var result = await _service.GetLocationByIdAsync(1);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(expectedLocation.id, result.id);
            Assert.Equal(expectedLocation.latitude, result.latitude);
            Assert.Equal(expectedLocation.longitude, result.longitude);
            Assert.Equal(expectedLocation.victim_id, result.victim_id);
        }

        [Fact]
        public async TaskAsync GetLocationByIdAsync_ThrowsKeyNotFoundException_WhenLocationDoesNotExist()
        {
            // Arrange
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync((Location)null);

            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(() => _service.GetLocationByIdAsync(1));
        }

        [Fact]
        public async TaskAsync UpdateLocationAsync_ReturnsUpdatedLocation_WhenUpdateSucceeds()
        {
            // Arrange
            var locationUpdateDto = new LocationUpdateDto
            {
                id = 1,
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            var existingLocation = new Location
            {
                id = 1,
                latitude = 39.4699,
                longitude = -0.3763,
                victim_id = 1
            };

            var updatedLocation = new Location
            {
                id = locationUpdateDto.id,
                latitude = locationUpdateDto.latitude,
                longitude = locationUpdateDto.longitude,
                victim_id = locationUpdateDto.victim_id
            };

            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(existingLocation);
            _mockLocationRepository.Setup(r => r.UpdateLocationAsync(It.IsAny<Location>()))
                .ReturnsAsync(updatedLocation);

            // Act
            var result = await _service.UpdateLocationAsync(1, locationUpdateDto);

            // Assert
            Assert.NotNull(result);
            Assert.Equal(updatedLocation.id, result.id);
            Assert.Equal(updatedLocation.latitude, result.latitude);
            Assert.Equal(updatedLocation.longitude, result.longitude);
            Assert.Equal(updatedLocation.victim_id, result.victim_id);
        }

        [Fact]
        public async TaskAsync UpdateLocationAsync_ThrowsArgumentException_WhenIdsDoNotMatch()
        {
            // Arrange
            var locationUpdateDto = new LocationUpdateDto { id = 2 };

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() => _service.UpdateLocationAsync(1, locationUpdateDto));
        }

        [Fact]
        public async TaskAsync DeleteLocationAsync_Succeeds_WhenLocationExists()
        {
            // Arrange
            var existingLocation = new Location { id = 1 };

            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(existingLocation);
            _mockLocationRepository.Setup(r => r.DeleteLocationAsync(1))
                .ReturnsAsync(true);

            // Act & Assert
            await _service.DeleteLocationAsync(1);
        }

        [Fact]
        public async TaskAsync DeleteLocationAsync_ThrowsKeyNotFoundException_WhenLocationDoesNotExist()
        {
            // Arrange
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync((Location)null);

            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(() => _service.DeleteLocationAsync(1));
        }

        [Fact]
        public async TaskAsync GetAllLocationsAsync_ReturnsLocations_WhenLocationsExist()
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

            _mockLocationRepository.Setup(r => r.GetAllLocationsAsync())
                .ReturnsAsync(expectedLocations);

            // Act
            var result = await _service.GetAllLocationsAsync();

            // Assert
            var locations = result.ToList();
            Assert.Single(locations);
            Assert.Equal(expectedLocations[0].id, locations[0].id);
            Assert.Equal(expectedLocations[0].latitude, locations[0].latitude);
            Assert.Equal(expectedLocations[0].longitude, locations[0].longitude);
            Assert.Equal(expectedLocations[0].victim_id, locations[0].victim_id);
        }

        [Fact]
        public async TaskAsync GetAffectedZoneByLocationIdAsync_ReturnsAffectedZones_WhenZonesExist()
        {
            // Arrange
            var expectedZones = new List<AffectedZone>
            {
                new AffectedZone
                {
                    id = 1,
                    name = "Test Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.High
                }
            };

            _mockLocationRepository.Setup(r => r.GetAffectedZoneByLocationIdAsync(1))
                .ReturnsAsync(expectedZones);

            // Act
            var result = await _service.GetAffectedZoneByLocationIdAsync(1);

            // Assert
            var zones = result.ToList();
            Assert.Single(zones);
            Assert.Equal(expectedZones[0].id, zones[0].id);
            Assert.Equal(expectedZones[0].name, zones[0].name);
            Assert.Equal(expectedZones[0].description, zones[0].description);
            Assert.Equal(expectedZones[0].hazard_level, zones[0].hazard_level);
        }

        [Fact]
        public async TaskAsync GetPaginatedLocationsAsync_ReturnsPaginatedLocations_WhenLocationsExist()
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

            _mockPaginationService.Setup(s => s.GetPaginatedAsync<Location>(1, 10, "location", "created_at DESC, id DESC"))
                .ReturnsAsync((expectedLocations, 1));

            // Act
            var (locations, totalCount) = await _service.GetPaginatedLocationsAsync(1, 10);

            // Assert
            var locationsList = locations.ToList();
            Assert.Single(locationsList);
            Assert.Equal(expectedLocations[0].id, locationsList[0].id);
            Assert.Equal(expectedLocations[0].latitude, locationsList[0].latitude);
            Assert.Equal(expectedLocations[0].longitude, locationsList[0].longitude);
            Assert.Equal(expectedLocations[0].victim_id, locationsList[0].victim_id);
            Assert.Equal(1, totalCount);
        }
    }
} 