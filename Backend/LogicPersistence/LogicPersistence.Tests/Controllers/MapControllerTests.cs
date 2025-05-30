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
    public class MapControllerTests
    {
        private readonly Mock<IMapServices> _mockMapServices;
        private readonly MapController _controller;

        public MapControllerTests()
        {
            _mockMapServices = new Mock<IMapServices>();
            _controller = new MapController(_mockMapServices.Object);
        }

        [Fact]
        public async TaskAsync GetAllVictimsWithLocationAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedVictims = new List<MapMarkerDTO>
            {
                new VictimMapMarkerDTO
                {
                    id = 1,
                    name = "Test Victim",
                    latitude = 39.4699,
                    longitude = -0.3763,
                    urgency_level = "High"
                }
            };

            _mockMapServices.Setup(s => s.GetAllVictimsWithLocationAsync())
                .ReturnsAsync(expectedVictims);

            // Act
            var result = await _controller.GetAllVictimsWithLocationAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<MapMarkerDTO>>(okResult.Value);
            Assert.Equal(expectedVictims.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllVolunteersWithLocationAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedVolunteers = new List<MapMarkerDTO>
            {
                new VolunteerMapMarkerDTO
                {
                    id = 1,
                    name = "Test Volunteer",
                    latitude = 39.4699,
                    longitude = -0.3763
                }
            };

            _mockMapServices.Setup(s => s.GetAllVolunteersWithLocationAsync())
                .ReturnsAsync(expectedVolunteers);

            // Act
            var result = await _controller.GetAllVolunteersWithLocationAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<MapMarkerDTO>>(okResult.Value);
            Assert.Equal(expectedVolunteers.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllAffectedZonesWithPointsAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedZones = new List<AffectedZoneWithPointsDTO>
            {
                new AffectedZoneWithPointsDTO
                {
                    id = 1,
                    name = "Test Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.High,
                    points = new List<LocationDisplayDto>
                    {
                        new() { latitude = 39.4699, longitude = -0.3763 },
                        new() { latitude = 39.4783, longitude = -0.3767 },
                        new() { latitude = 39.4557, longitude = -0.3521 }
                    }
                }
            };

            _mockMapServices.Setup(s => s.GetAllAffectedZonesWithPointsAsync())
                .ReturnsAsync(expectedZones);

            // Act
            var result = await _controller.GetAllAffectedZonesWithPointsAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<AffectedZoneWithPointsDTO>>(okResult.Value);
            Assert.Equal(expectedZones.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllTasksWithLocationAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedTasks = new List<TaskMapMarkerDTO>
            {
                new TaskMapMarkerDTO
                {
                    id = 1,
                    name = "Test Task",
                    latitude = 39.4699,
                    longitude = -0.3763,
                    state = "In Progress",
                    assigned_volunteers = new List<Volunteer>(),
                    skills_with_level = new Dictionary<string, string>()
                }
            };

            _mockMapServices.Setup(s => s.GetAllTasksWithLocationAsync())
                .ReturnsAsync(expectedTasks);

            // Act
            var result = await _controller.GetAllTasksWithLocationAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<TaskMapMarkerDTO>>(okResult.Value);
            Assert.Equal(expectedTasks.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllPickupPointsWithLocationAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedPoints = new List<PickupPointMapMarkerDTO>
            {
                new PickupPointMapMarkerDTO
                {
                    id = 1,
                    name = "Test Pickup Point",
                    latitude = 39.4699,
                    longitude = -0.3763,
                    physical_donation = new List<PhysicalDonation>()
                }
            };

            _mockMapServices.Setup(s => s.GetAllPickupPointsWithLocationAsync())
                .ReturnsAsync(expectedPoints);

            // Act
            var result = await _controller.GetAllPickupPointsWithLocationAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<PickupPointMapMarkerDTO>>(okResult.Value);
            Assert.Equal(expectedPoints.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllMeetingPointsWithLocationAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedPoints = new List<MeetingPointMapMarkerDTO>
            {
                new MeetingPointMapMarkerDTO
                {
                    id = 1,
                    name = "Test Meeting Point",
                    latitude = 39.4699,
                    longitude = -0.3763
                }
            };

            _mockMapServices.Setup(s => s.GetAllMeetingPointsWithLocationAsync())
                .ReturnsAsync(expectedPoints);

            // Act
            var result = await _controller.GetAllMeetingPointsWithLocationAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<MeetingPointMapMarkerDTO>>(okResult.Value);
            Assert.Equal(expectedPoints.Count(), returnValue.Count());
        }

        [Fact]
        public async TaskAsync GetAllRiskZonesWithPointsAsync_ReturnsOkResult_WhenServiceSucceeds()
        {
            // Arrange
            var expectedZones = new List<AffectedZoneWithPointsDTO>
            {
                new AffectedZoneWithPointsDTO
                {
                    id = 1,
                    name = "Test Risk Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.None,
                    points = new List<LocationDisplayDto>
                    {
                        new() { latitude = 39.4699, longitude = -0.3763 },
                        new() { latitude = 39.4783, longitude = -0.3767 },
                        new() { latitude = 39.4557, longitude = -0.3521 }
                    }
                }
            };

            _mockMapServices.Setup(s => s.GetAllRiskZonesWithPointsAsync())
                .ReturnsAsync(expectedZones);

            // Act
            var result = await _controller.GetAllRiskZonesWithPointsAsync();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsAssignableFrom<IEnumerable<AffectedZoneWithPointsDTO>>(okResult.Value);
            Assert.Equal(expectedZones.Count(), returnValue.Count());
        }
    }
} 