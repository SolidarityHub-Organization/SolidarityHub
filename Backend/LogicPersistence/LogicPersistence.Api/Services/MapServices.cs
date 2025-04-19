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

        public MapServices(ILocationRepository locationRepository, IVictimRepository victimRepository, IVolunteerRepository volunteerRepository, IAffectedZoneRepository affectedZoneRepository) {
            _affectedZoneRepository = affectedZoneRepository;
            _locationRepository = locationRepository;
            _victimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
        }

        public async Task<IEnumerable<UserLocationDTO>> GetAllVictimsWithLocationAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			var victimsWithLocation = victims.Where(v => v.location_id != null).ToList(); 
			var result = new List<UserLocationDTO>();
			foreach (var victim in victimsWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(victim.location_id.Value);
				result.Add(new UserLocationDTO {
					id = victim.id,
					name = victim.name,
					role = "victim",
					latitude = location.latitude,
					longitude = location.longitude,
				});
			}
			return result;
		}

        public async Task<IEnumerable<UserLocationDTO>> GetAllVolunteersWithLocationAsync() {
			var volunteers = await _volunteerRepository.GetAllVolunteersAsync();
			if (volunteers == null) {
				throw new InvalidOperationException("Failed to retrieve volunteers.");
			}
			var volunteersWithLocation = volunteers.Where(v => v.location_id != null).ToList();
			var result = new List<UserLocationDTO>();
			foreach (var volunteer in volunteersWithLocation) {
				var location = await _locationRepository.GetLocationByIdAsync(volunteer.location_id.Value);
				result.Add(new UserLocationDTO {
					id = volunteer.id,
					name = volunteer.name,
					role = "volunteer",
					latitude = location.latitude,
					longitude = location.longitude,
				});
			}
			return result;
		}

        public async Task<IEnumerable<UserLocationDTO>> GetAllUsersWithLocationAsync() {
			var result = new List<UserLocationDTO>();
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
    }
}