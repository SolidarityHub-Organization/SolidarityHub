using LogicPersistence.Api.Functionalities;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using Microsoft.OpenApi.Extensions;

namespace LogicPersistence.Api.Services {
    public class MapServices : IMapServices {
        private readonly ILocationRepository _locationRepository;
        private readonly IVictimRepository _victimRepository;
        private readonly IVolunteerRepository _volunteerRepository;
        private readonly IAffectedZoneRepository _affectedZoneRepository;
        private readonly ITaskRepository _taskRepository;
        private readonly IPointRepository _pointRepository;

        public MapServices(ILocationRepository locationRepository, IVictimRepository victimRepository, IVolunteerRepository volunteerRepository, IAffectedZoneRepository affectedZoneRepository, ITaskRepository taskRepository, IPointRepository pointRepository) {
            _affectedZoneRepository = affectedZoneRepository;
            _locationRepository = locationRepository;
            _victimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
            _taskRepository = taskRepository;
            _pointRepository = pointRepository;
        }

        #region Public Methods
        public async Task<IEnumerable<MapMarkerDTO>> GetAllVictimsWithLocationAsync() {
            var victims = await _victimRepository.GetAllVictimsAsync() ?? throw new InvalidOperationException("Failed to retrieve .");
            var result = new List<VictimMapMarkerDTO>();

            foreach (var victim in victims.Where(v => v.location_id.HasValue)) {
                var location = await _locationRepository.GetLocationByIdAsync(victim.location_id.Value);
                var urgencyLevel = await _victimRepository.GetVictimMaxUrgencyLevelByIdAsync(victim.id);

                var victimDto = await MapMarkerFactory.CreateBaseMapMarker<VictimMapMarkerDTO>(victim, location);
                victimDto.urgency_level = LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(urgencyLevel);

                result.Add(victimDto);
            }

            return result;
        }

        public async Task<IEnumerable<MapMarkerDTO>> GetAllVolunteersWithLocationAsync() {
            var volunteers = await _volunteerRepository.GetAllVolunteersAsync() ?? throw new InvalidOperationException("Failed to retrieve volunteers."); 
            var result = new List<VolunteerMapMarkerDTO>();

            foreach (var volunteer in volunteers.Where(v => v.location_id.HasValue)) {
                var location = await _locationRepository.GetLocationByIdAsync(volunteer.location_id.Value);
                result.Add(await MapMarkerFactory.CreateBaseMapMarker<VolunteerMapMarkerDTO>(volunteer, location));
            }

            return result;
        }

        public async Task<IEnumerable<MapMarkerDTO>> GetAllUsersWithLocationAsync() {
            var victims = await GetAllVictimsWithLocationAsync();
            var volunteers = await GetAllVolunteersWithLocationAsync();

            return victims.Concat(volunteers);
        }

        public async Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllAffectedZonesWithPointsAsync() {
            return await GetAllZonesWithPointsAsync(isAffectedZone: true);
        }

        public async Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllRiskZonesWithPointsAsync() {
            return await GetAllZonesWithPointsAsync(isAffectedZone: false);
        }

        public async Task<IEnumerable<TaskMapMarkerDTO>> GetAllTasksWithLocationAsync() {
            var tasks = await _taskRepository.GetAllTasksWithDetailsAsync() ?? throw new InvalidOperationException("Failed to retrieve tasks."); ;
            var result = new List<TaskMapMarkerDTO>();

            foreach (var task in tasks) {
                var location = await _locationRepository.GetLocationByIdAsync(task.location_id);
                var taskState = await _taskRepository.GetTaskStateByIdAsync(task.id);
                var assignedVolunteers = await GetAssignedVolunteers(task.assigned_volunteers);
                var taskSkills = await GetTaskSkillsWithLevelAsync(task.id);

                var taskDto = await MapMarkerFactory.CreateBaseMapMarker<TaskMapMarkerDTO>(task, location);
                taskDto.state = LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(taskState);
                taskDto.assigned_volunteers = assignedVolunteers;
                taskDto.skills_with_level = taskSkills;

                result.Add(taskDto);
            }

            return result;
        }

        public async Task<IEnumerable<PickupPointMapMarkerDTO>> GetAllPickupPointsWithLocationAsync() {
            var pickupPoints = await _pointRepository.GetAllPickupPointsAsync() ?? throw new InvalidOperationException("Failed to retrieve pickup points.");
            var result = new List<PickupPointMapMarkerDTO>();

            foreach (var pickupPoint in pickupPoints) {
                var location = await _locationRepository.GetLocationByIdAsync(pickupPoint.location_id);
                var physicalDonations = await _pointRepository.GetPhysicalDonationsByPickupPointIdAsync(pickupPoint.id);

                var pickupPointDto = await MapMarkerFactory.CreateBaseMapMarker<PickupPointMapMarkerDTO>(pickupPoint, location);
                pickupPointDto.physical_donation = physicalDonations.ToList();

                result.Add(pickupPointDto);
            }

            return result;
        }

        public async Task<IEnumerable<MeetingPointMapMarkerDTO>> GetAllMeetingPointsWithLocationAsync() {
            var meetingPoints = await _pointRepository.GetAllMeetingPointsAsync() ?? throw new InvalidOperationException("Failed to retrieve meeting points.");
            var result = new List<MeetingPointMapMarkerDTO>();

            foreach (var meetingPoint in meetingPoints) {
                var location = await _locationRepository.GetLocationByIdAsync(meetingPoint.location_id);
                result.Add(await MapMarkerFactory.CreateBaseMapMarker<MeetingPointMapMarkerDTO>(meetingPoint, location));
            }

            return result;
        }

        #endregion
        #region Internal Methods
        internal async Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllZonesWithPointsAsync(bool isAffectedZone) {
            var allZones = await _affectedZoneRepository.GetAllAffectedZonesAsync() ?? throw new InvalidOperationException("Failed to retrieve zones.");
            var filteredZones = isAffectedZone ? allZones.Where(z => z.hazard_level != HazardLevel.None) : allZones.Where(z => z.hazard_level == HazardLevel.None);
            var result = new List<AffectedZoneWithPointsDTO>();

            foreach (var zone in filteredZones) {
                var points = await _locationRepository.GetLocationsByAffectedZoneIdAsync(zone.id);

                if (points.Count() >= 3) {
                    result.Add(new AffectedZoneWithPointsDTO {
                        id = zone.id,
                        name = zone.name,
                        description = zone.description,
                        hazard_level = zone.hazard_level,
                        admin_id = zone.admin_id,
                        points = points.Select(p => p.ToLocationDisplayDto()).ToList()
                    });
                }
            }

            return result;
        }

        internal async Task<IEnumerable<Volunteer>> GetAssignedVolunteers(IEnumerable<VolunteerDisplayDto> assignedVolunteers) {
            var result = new List<Volunteer>();

            foreach (var volunteer in assignedVolunteers) {
                var retrievedVolunteer = await _volunteerRepository.GetVolunteerByIdAsync(volunteer.id);

                if (retrievedVolunteer != null) {
                    result.Add(retrievedVolunteer);
                }
            }

            return result;
        }

        internal async Task<Dictionary<string, string>> GetTaskSkillsWithLevelAsync(int taskId) {
            var skills = await _taskRepository.GetTaskSkillsAsync(taskId) ?? throw new InvalidOperationException("Failed to retrieve task skills.");

            return skills.ToDictionary(skill => skill.name, skill => LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(skill.level));
        }

#endregion

    }
}
