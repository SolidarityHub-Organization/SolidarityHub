using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services {
    public class MapServices : IMapServices {
        private readonly ILocationRepository _locationRepository;
		private readonly IVictimRepository _victimRepository;
		private readonly IVolunteerRepository _volunteerRepository;
        private readonly IAffectedZoneRepository _affectedZoneRepository;
        private readonly ITaskRepository _taskRepository;

        public MapServices(ILocationRepository locationRepository, IVictimRepository victimRepository, IVolunteerRepository volunteerRepository, IAffectedZoneRepository affectedZoneRepository, ITaskRepository taskRepository) {
            _affectedZoneRepository = affectedZoneRepository;
            _locationRepository = locationRepository;
            _victimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
            _taskRepository = taskRepository;
        }

        public async Task<IEnumerable<MapMarkerDTO>> GetAllVictimsWithLocationAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			var victimsWithLocation = victims.Where(v => v.location_id != null).ToList(); 
			var result = new List<MapMarkerDTO>();
			foreach (var victim in victimsWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(victim.location_id.Value);
				result.Add(new MapMarkerDTO {
					id = victim.id,
					name = victim.name,
					type = "victim",
					latitude = location.latitude,
					longitude = location.longitude,
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
			var result = new List<MapMarkerDTO>();
			foreach (var volunteer in volunteersWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(volunteer.location_id.Value);
				result.Add(new MapMarkerDTO {
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
            foreach (var affectedZone in affectedZones) 
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

        public async Task<IEnumerable<MapMarkerDTO>> GetAllTasksWithLocationAsync() {
            var tasks = await _taskRepository.GetAllTasksAsync();
            if (tasks == null) {
                throw new InvalidOperationException("Failed to retrieve tasks.");
            }
            var result = new List<MapMarkerDTO>();
            foreach (var task in tasks) {
                var location = await _locationRepository.GetLocationByIdAsync(task.location_id);
                result.Add(new MapMarkerDTO {
                    id = task.id,
                    name = task.name,
                    type = "task",
                    latitude = location.latitude,
                    longitude = location.longitude,
                });
            }
            return result;
        }
    }
}