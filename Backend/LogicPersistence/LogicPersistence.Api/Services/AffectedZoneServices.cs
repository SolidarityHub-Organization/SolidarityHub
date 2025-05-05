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

#region Internal methods

        public static bool IsPointInAffectedZone(double latitude, double longitude, AffectedZoneWithPointsDTO affectedZone)
        {
            if (affectedZone == null || affectedZone.points == null || affectedZone.points.Count == 0) {
                return false;
            }

            bool isInside = false;
            int j = affectedZone.points.Count - 1;

            for (int i = 0; i < affectedZone.points.Count; i++)
            {
                var pointI = affectedZone.points[i];
                var pointJ = affectedZone.points[j];


                if (((pointI.latitude > latitude) != (pointJ.latitude > latitude)) &&
                    (longitude < (pointJ.longitude - pointI.longitude) * (latitude - pointI.latitude) / 
                    (pointJ.latitude - pointI.latitude) + pointI.longitude))
                {
                    isInside = !isInside;
                }

                j = i;
            }

            return isInside;
        }
#endregion
    }
    
}