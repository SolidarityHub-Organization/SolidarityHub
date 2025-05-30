using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;
using Moq;
using Xunit;
using TaskAsync = System.Threading.Tasks.Task;

namespace LogicPersistence.Tests.Services
{
    public class MapServicesTests
    {
        private readonly Mock<ILocationRepository> _mockLocationRepository;
        private readonly Mock<IVictimRepository> _mockVictimRepository;
        private readonly Mock<IVolunteerRepository> _mockVolunteerRepository;
        private readonly Mock<IAffectedZoneRepository> _mockAffectedZoneRepository;
        private readonly Mock<ITaskRepository> _mockTaskRepository;
        private readonly Mock<IPointRepository> _mockPointRepository;
        private readonly MapServices _service;

        public MapServicesTests()
        {
            _mockLocationRepository = new Mock<ILocationRepository>();
            _mockVictimRepository = new Mock<IVictimRepository>();
            _mockVolunteerRepository = new Mock<IVolunteerRepository>();
            _mockAffectedZoneRepository = new Mock<IAffectedZoneRepository>();
            _mockTaskRepository = new Mock<ITaskRepository>();
            _mockPointRepository = new Mock<IPointRepository>();

            _service = new MapServices(
                _mockLocationRepository.Object,
                _mockVictimRepository.Object,
                _mockVolunteerRepository.Object,
                _mockAffectedZoneRepository.Object,
                _mockTaskRepository.Object,
                _mockPointRepository.Object
            );
        }

        [Fact]
        public async TaskAsync GetAllVictimsWithLocationAsync_ReturnsVictimMapMarkers()
        {
            // Arrange
            var victims = new List<Victim>
            {
                new Victim { id = 1, name = "Test", surname = "Victim", location_id = 1 }
            };

            var location = new Location { id = 1, latitude = 39.4699, longitude = -0.3763 };

            _mockVictimRepository.Setup(r => r.GetAllVictimsAsync())
                .ReturnsAsync(victims);
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(location);
            _mockVictimRepository.Setup(r => r.GetVictimMaxUrgencyLevelByIdAsync(1))
                .ReturnsAsync(UrgencyLevel.High);

            // Act
            var result = await _service.GetAllVictimsWithLocationAsync();

            // Assert
            var markers = result.ToList();
            Assert.Single(markers);
            var marker = markers[0] as VictimMapMarkerDTO;
            Assert.NotNull(marker);
            Assert.Equal(victims[0].id, marker.id);
            Assert.Equal($"{victims[0].name} {victims[0].surname}", marker.name);
            Assert.Equal(location.latitude, marker.latitude);
            Assert.Equal(location.longitude, marker.longitude);
            Assert.Equal("Alto", marker.urgency_level);
        }

        [Fact]
        public async TaskAsync GetAllVolunteersWithLocationAsync_ReturnsVolunteerMapMarkers()
        {
            // Arrange
            var volunteers = new List<Volunteer>
            {
                new Volunteer { 
                    id = 1, 
                    name = "Test", 
                    surname = "Volunteer", 
                    location_id = 1,
                    phone_number = "+34123456789"
                }
            };

            var location = new Location { id = 1, latitude = 39.4699, longitude = -0.3763 };

            _mockVolunteerRepository.Setup(r => r.GetAllVolunteersAsync())
                .ReturnsAsync(volunteers);
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(location);

            // Act
            var result = await _service.GetAllVolunteersWithLocationAsync();

            // Assert
            var markers = result.ToList();
            Assert.Single(markers);
            var marker = markers[0] as VolunteerMapMarkerDTO;
            Assert.NotNull(marker);
            Assert.Equal(volunteers[0].id, marker.id);
            Assert.Equal($"{volunteers[0].name} {volunteers[0].surname}", marker.name);
            Assert.Equal(location.latitude, marker.latitude);
            Assert.Equal(location.longitude, marker.longitude);
        }

        [Fact]
        public async TaskAsync GetAllAffectedZonesWithPointsAsync_ReturnsAffectedZones()
        {
            // Arrange
            var zones = new List<AffectedZone>
            {
                new AffectedZone
                {
                    id = 1,
                    name = "Test Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.High
                }
            };

            var points = new List<Location>
            {
                new() { latitude = 39.4699, longitude = -0.3763 },
                new() { latitude = 39.4783, longitude = -0.3767 },
                new() { latitude = 39.4557, longitude = -0.3521 }
            };

            _mockAffectedZoneRepository.Setup(r => r.GetAllAffectedZonesAsync())
                .ReturnsAsync(zones);
            _mockLocationRepository.Setup(r => r.GetLocationsByAffectedZoneIdAsync(1))
                .ReturnsAsync(points);

            // Act
            var result = await _service.GetAllAffectedZonesWithPointsAsync();

            // Assert
            var zonesList = result.ToList();
            Assert.Single(zonesList);
            Assert.Equal(zones[0].id, zonesList[0].id);
            Assert.Equal(zones[0].name, zonesList[0].name);
            Assert.Equal(zones[0].description, zonesList[0].description);
            Assert.Equal(zones[0].hazard_level, zonesList[0].hazard_level);
            Assert.Equal(3, zonesList[0].points.Count());
        }

        [Fact]
        public async TaskAsync GetAllTasksWithLocationAsync_ReturnsTaskMapMarkers()
        {
            // Arrange
            var tasks = new List<TaskWithDetailsDto>
            {
                new TaskWithDetailsDto { 
                    id = 1, 
                    name = "Test Task", 
                    location_id = 1,
                    description = "Test Description",
                    admin_id = null,
                    start_date = DateTime.Now,
                    end_date = null
                }
            };

            var location = new Location { id = 1, latitude = 39.4699, longitude = -0.3763 };
            var taskState = State.Assigned;
            var assignedVolunteers = new List<Volunteer>();
            var taskSkills = new Dictionary<string, string>();

            _mockTaskRepository.Setup(r => r.GetAllTasksWithDetailsAsync())
                .ReturnsAsync(tasks);
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(location);
            _mockTaskRepository.Setup(r => r.GetTaskStateByIdAsync(1))
                .ReturnsAsync(taskState);

            // Act
            var result = await _service.GetAllTasksWithLocationAsync();

            // Assert
            var markers = result.ToList();
            Assert.Single(markers);
            var marker = markers[0] as TaskMapMarkerDTO;
            Assert.NotNull(marker);
            Assert.Equal(tasks[0].id, marker.id);
            Assert.Equal(tasks[0].name, marker.name);
            Assert.Equal(location.latitude, marker.latitude);
            Assert.Equal(location.longitude, marker.longitude);
            Assert.Equal("Asignado", marker.state);
        }

        [Fact]
        public async TaskAsync GetAllPickupPointsWithLocationAsync_ReturnsPickupPointMapMarkers()
        {
            // Arrange
            var pickupPoints = new List<PickupPoint>
            {
                new PickupPoint { id = 1, name = "Test Point", location_id = 1 }
            };

            var location = new Location { id = 1, latitude = 39.4699, longitude = -0.3763 };
            var physicalDonations = new List<PhysicalDonation>();

            _mockPointRepository.Setup(r => r.GetAllPickupPointsAsync())
                .ReturnsAsync(pickupPoints);
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(location);
            _mockPointRepository.Setup(r => r.GetPhysicalDonationsByPickupPointIdAsync(1))
                .ReturnsAsync(physicalDonations);

            // Act
            var result = await _service.GetAllPickupPointsWithLocationAsync();

            // Assert
            var markers = result.ToList();
            Assert.Single(markers);
            var marker = markers[0] as PickupPointMapMarkerDTO;
            Assert.NotNull(marker);
            Assert.Equal(pickupPoints[0].id, marker.id);
            Assert.Equal(pickupPoints[0].name, marker.name);
            Assert.Equal(location.latitude, marker.latitude);
            Assert.Equal(location.longitude, marker.longitude);
            Assert.Empty(marker.physical_donation);
        }

        [Fact]
        public async TaskAsync GetAllMeetingPointsWithLocationAsync_ReturnsMeetingPointMapMarkers()
        {
            // Arrange
            var meetingPoints = new List<MeetingPoint>
            {
                new MeetingPoint { id = 1, name = "Test Point", location_id = 1 }
            };

            var location = new Location { id = 1, latitude = 39.4699, longitude = -0.3763 };

            _mockPointRepository.Setup(r => r.GetAllMeetingPointsAsync())
                .ReturnsAsync(meetingPoints);
            _mockLocationRepository.Setup(r => r.GetLocationByIdAsync(1))
                .ReturnsAsync(location);

            // Act
            var result = await _service.GetAllMeetingPointsWithLocationAsync();

            // Assert
            var markers = result.ToList();
            Assert.Single(markers);
            var marker = markers[0] as MeetingPointMapMarkerDTO;
            Assert.NotNull(marker);
            Assert.Equal(meetingPoints[0].id, marker.id);
            Assert.Equal(meetingPoints[0].name, marker.name);
            Assert.Equal(location.latitude, marker.latitude);
            Assert.Equal(location.longitude, marker.longitude);
        }

        [Fact]
        public async TaskAsync GetAllRiskZonesWithPointsAsync_ReturnsRiskZones()
        {
            // Arrange
            var zones = new List<AffectedZone>
            {
                new AffectedZone
                {
                    id = 1,
                    name = "Test Zone",
                    description = "Test Description",
                    hazard_level = HazardLevel.None
                }
            };

            var points = new List<Location>
            {
                new() { latitude = 39.4699, longitude = -0.3763 },
                new() { latitude = 39.4783, longitude = -0.3767 },
                new() { latitude = 39.4557, longitude = -0.3521 }
            };

            _mockAffectedZoneRepository.Setup(r => r.GetAllAffectedZonesAsync())
                .ReturnsAsync(zones);
            _mockLocationRepository.Setup(r => r.GetLocationsByAffectedZoneIdAsync(1))
                .ReturnsAsync(points);

            // Act
            var result = await _service.GetAllRiskZonesWithPointsAsync();

            // Assert
            var zonesList = result.ToList();
            Assert.Single(zonesList);
            Assert.Equal(zones[0].id, zonesList[0].id);
            Assert.Equal(zones[0].name, zonesList[0].name);
            Assert.Equal(zones[0].description, zonesList[0].description);
            Assert.Equal(zones[0].hazard_level, zonesList[0].hazard_level);
            Assert.Equal(3, zonesList[0].points.Count());
        }
    }
} 