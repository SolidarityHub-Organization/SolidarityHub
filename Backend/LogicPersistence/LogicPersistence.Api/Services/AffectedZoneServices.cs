using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;

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
            return affectedZones;
        }


    }
    
}