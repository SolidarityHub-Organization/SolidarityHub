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

        public async Task<IEnumerable<MapMarkerDTO>> GetAllVictimsWithLocationAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			var victimsWithLocation = victims.Where(v => v.location_id != null).ToList(); 
			var result = new List<VictimMapMarkerDTO>();
			foreach (var victim in victimsWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(victim.location_id.Value);
                var urgencyLevel = await _victimRepository.GetVictimMaxUrgencyLevelByIdAsync(victim.id);

				result.Add(new VictimMapMarkerDTO {
					id = victim.id,
					name = victim.name,
					type = "victim",
					latitude = location.latitude,
					longitude = location.longitude,
                    urgency_level = LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(urgencyLevel),
				});
			}
			return result;
		}

        public async Task<IEnumerable<MapMarkerDTO>> GetAllVolunteersWithLocationAsync() {
			var volunteers = await _volunteerRepository.GetAllVolunteersAsync();
			if (volunteers == null) {
				throw new InvalidOperationException("Failed to retrieve volunteers.");
			}
			var volunteersWithLocation = volunteers.Where(v => v.location_id != null).ToList();
			var result = new List<VolunteerMapMarkerDTO>();
			foreach (var volunteer in volunteersWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(volunteer.location_id.Value);
				result.Add(new VolunteerMapMarkerDTO {
					id = volunteer.id,
					name = volunteer.name,
					type = "volunteer",
					latitude = location.latitude,
					longitude = location.longitude,
				});
			}
			return result;
		}

        public async Task<IEnumerable<MapMarkerDTO>> GetAllUsersWithLocationAsync() {
			var result = new List<MapMarkerDTO>();
            result.AddRange(await GetAllVictimsWithLocationAsync());
            result.AddRange(await GetAllVolunteersWithLocationAsync());
            return result;
		}

        public async Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllAffectedZonesWithPointsAsync() 
        {
            var affectedZones = await _affectedZoneRepository.GetAllAffectedZonesAsync();
            if (affectedZones == null) 
            {
                throw new InvalidOperationException("Failed to retrieve affected zones.");
            }
            var result = new List<AffectedZoneWithPointsDTO>();
            foreach (var affectedZone in affectedZones.Where(a => a.hazard_level != HazardLevel.None)) 
            {
                var points = await _locationRepository.GetLocationsByAffectedZoneIdAsync(affectedZone.id);
                if (points.ToList().Count >= 3) {
                    result.Add(new AffectedZoneWithPointsDTO {
                        id = affectedZone.id,
                        name = affectedZone.name,
                        description = affectedZone.description,
                        hazard_level = affectedZone.hazard_level,
                        admin_id = affectedZone.admin_id,
                        points = points.Select(p => p.ToLocationDisplayDto()).ToList()
                    });
                }
                
            }
            return result;
        }

        public async Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllRiskZonesWithPointsAsync() 
        {
            var affectedZones = await _affectedZoneRepository.GetAllAffectedZonesAsync();
            if (affectedZones == null) 
            {
                throw new InvalidOperationException("Failed to retrieve risk zones.");
            }
            var result = new List<AffectedZoneWithPointsDTO>();
            foreach (var riskZone in affectedZones.Where(a => a.hazard_level == HazardLevel.None)) 
            {
                var points = await _locationRepository.GetLocationsByAffectedZoneIdAsync(riskZone.id);
                if (points.ToList().Count >= 3) {
                    result.Add(new AffectedZoneWithPointsDTO {
                        id = riskZone.id,
                        name = riskZone.name,
                        description = riskZone.description,
                        hazard_level = riskZone.hazard_level,
                        admin_id = riskZone.admin_id,
                        points = points.Select(p => p.ToLocationDisplayDto()).ToList()
                    });
                }
                
            }
            return result;
        }

        public async Task<IEnumerable<MapMarkerDTO>> GetAllTasksWithLocationAsync() {
            var tasks = await _taskRepository.GetAllTasksWithDetailsAsync();
            if (tasks == null) {
                throw new InvalidOperationException("Failed to retrieve tasks.");
            }
            var result = new List<TaskMapMarkerDTO>();
            foreach (var task in tasks) {
                var location = await _locationRepository.GetLocationByIdAsync(task.location_id);
                var taskState = await _taskRepository.GetTaskStateByIdAsync(task.id);
                var assignedVolunteersIds = task.assigned_volunteers.Select(v => v.id).ToList();
                var assignedVolunteers = new List<Volunteer>();

                foreach (var id in assignedVolunteersIds) {
                    var volunteer = await _volunteerRepository.GetVolunteerByIdAsync(id);
                    if (volunteer != null) {
                        assignedVolunteers.Add(volunteer);
                    }   
                }
                
                result.Add(new TaskMapMarkerDTO {
                    id = task.id,
                    name = task.name,
                    type = "task",
                    latitude = location.latitude,
                    longitude = location.longitude,
                    state = LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(taskState),
                    assigned_volunteers = assignedVolunteers.ToList(),
                });
            }
            return result;
        }

        public async Task<IEnumerable<PickupPointMapMarkerDTO>> GetAllPickupPointsWithLocationAsync() {
            var pickupPoints = await _pointRepository.GetAllPickupPointsAsync();
            if (pickupPoints == null) {
                throw new InvalidOperationException("Failed to retrieve pickup points.");
            }

            var result = new List<PickupPointMapMarkerDTO>();

            foreach (var pickupPoint in pickupPoints) {
                var location = await _locationRepository.GetLocationByIdAsync(pickupPoint.location_id);
                var physicalDonations = await _pointRepository.GetPhysicalDonationsByPickupPointIdAsync(pickupPoint.id);

                result.Add(new PickupPointMapMarkerDTO {
                    id = pickupPoint.id,
                    name = pickupPoint.name,
                    type = "pickup_point",
                    latitude = location.latitude,
                    longitude = location.longitude,
                    physical_donation = physicalDonations.ToList(),
                });
            }

            return result;       
        }

        public async Task<IEnumerable<MeetingPointMapMarkerDTO>> GetAllMeetingPointsWithLocationAsync() {
            var meetingPoints = await _pointRepository.GetAllMeetingPointsAsync();
            if (meetingPoints == null) {
                throw new InvalidOperationException("Failed to retrieve meeting points.");
            }

            var result = new List<MeetingPointMapMarkerDTO>();

            foreach (var meetingPoint in meetingPoints) {
                var location = await _locationRepository.GetLocationByIdAsync(meetingPoint.location_id);
                var attendingVolunteers = await _pointRepository.GetVolunteersByMeetingPointIdAsync(meetingPoint.id);

                result.Add(new MeetingPointMapMarkerDTO {
                    id = meetingPoint.id,
                    name = meetingPoint.name,
                    type = "meeting_point",
                    latitude = location.latitude,
                    longitude = location.longitude,
                    attending_volunteers = attendingVolunteers.ToList(),
                });
            }

            return result;
        }         
    }
}