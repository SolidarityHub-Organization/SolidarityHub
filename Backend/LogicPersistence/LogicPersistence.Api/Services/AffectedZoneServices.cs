using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{

    public class AffectedZoneServices : IAffectedZoneServices
    {
        private readonly IAffectedZoneRepository _affectedZoneRepository;

        public AffectedZoneServices(IAffectedZoneRepository affectedZoneRepository)
        {
            _affectedZoneRepository = affectedZoneRepository;
        }

        public async Task<AffectedZone> CreateAffectedZoneAsync(AffectedZoneCreateDto affectedZoneCreateDto)
        {
            if (affectedZoneCreateDto == null) {
                throw new ArgumentNullException(nameof(affectedZoneCreateDto));
            }

            var affectedZone = await _affectedZoneRepository.CreateAffectedZoneAsync(affectedZoneCreateDto.ToAffectedZone());
            if (affectedZone == null) {
                throw new InvalidOperationException("Failed to create affected zone.");
            }

            return affectedZone;
        }

        public async Task<AffectedZone> UpdateAffectedZoneAsync(int id,AffectedZoneUpdateDto affectedZoneUpdateDto) 
        {
            if (id != affectedZoneUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingAffectedZone = await _affectedZoneRepository.GetAffectedZoneByIdAsync(id);
            if (existingAffectedZone == null) {
                throw new KeyNotFoundException($"Affected zone with id {id} not found.");
            }
            var updatedAffectedZone = affectedZoneUpdateDto.ToAffectedZone();
            await _affectedZoneRepository.UpdateAffectedZoneAsync(updatedAffectedZone);
            return updatedAffectedZone;
        }

        public async System.Threading.Tasks.Task DeleteAffectedZoneAsync(int id) 
        {
            var existingAffectedZone = await _affectedZoneRepository.GetAffectedZoneByIdAsync(id);
            if (existingAffectedZone == null) {
                throw new KeyNotFoundException($"Affected zone with id {id} not found.");
            }

            var deletionSuccesful = await _affectedZoneRepository.DeleteAffectedZoneAsync(id);
            if (!deletionSuccesful) {
                throw new InvalidOperationException($"Failed to delete affected zone with id {id}.");
            }
        }

        public async Task<AffectedZone> GetAffectedZoneByIdAsync(int id) 
        {
            var affectedZone = await _affectedZoneRepository.GetAffectedZoneByIdAsync(id);
            if (affectedZone == null) {
                throw new KeyNotFoundException($"Affected zone with id {id} not found.");
            }
            return affectedZone;
        }
        public async Task<IEnumerable<AffectedZone>> GetAllAffectedZonesAsync() 
        {
            var affectedZones = await _affectedZoneRepository.GetAllAffectedZonesAsync();
            if (affectedZones == null) {
                throw new InvalidOperationException("Failed to retrieve affected zones.");
            }
            return affectedZones.Where(a => a.hazard_level != HazardLevel.None).ToList();
        }

        public async Task<IEnumerable<AffectedZone>> GetAllRiskZonesAsync() 
        {
            var affectedZones = await _affectedZoneRepository.GetAllAffectedZonesAsync();
            if (affectedZones == null) {
                throw new InvalidOperationException("Failed to retrieve risk zones.");
            }
            return affectedZones.Where(a => a.hazard_level == HazardLevel.None).ToList();
        }

        public static bool IsPointInAffectedZone(double latitude, double longitude, AffectedZoneWithPointsDTO affectedZone)
        {
            if (affectedZone?.points == null || affectedZone.points.Count == 0)
                return false;


            bool isInside = false;
            int pointCount = affectedZone.points.Count;

            for (int i = 0, j = pointCount - 1; i < pointCount; j = i++)
            {
                var pi = affectedZone.points[i];
                var pj = affectedZone.points[j];

                bool intersects = ((pi.latitude > latitude) != (pj.latitude > latitude)) &&
                                  (longitude < (pj.longitude - pi.longitude) * (latitude - pi.latitude) /
                                  (pj.latitude - pi.latitude) + pi.longitude);

                if (intersects)
                    isInside = !isInside;
            }

            return isInside;
        }
    }
}