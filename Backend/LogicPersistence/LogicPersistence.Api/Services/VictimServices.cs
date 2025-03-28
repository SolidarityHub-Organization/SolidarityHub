using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;


// The services are the classes that contain the business logic of the application. They are responsible for processing the data and performing the necessary operations to fulfill the requests from the client passed from the controllers.
// It must be attached to the repository to be able to perform the necessary operations on the database.

namespace LogicPersistence.Api.Services
{
    public class VictimServices : IVictimServices
    {
        private readonly IVictimRepository _victimRepository;

        public VictimServices(IVictimRepository victimRepository)
        {
            _victimRepository = victimRepository;
        }


        public async Task<Victim> CreateVictimAsync(VictimCreateDto victimCreateDto)
        {
            if (victimCreateDto == null)
            {
                throw new ArgumentNullException(nameof(victimCreateDto));
            }
            
            var victim = await _victimRepository.CreateVictimAsync(victimCreateDto.ToVictim());
            if (victim == null)
            {
                throw new InvalidOperationException("Failed to create victim.");
            }

            return victim;
        }

        public async Task<Victim> GetVictimByIdAsync(int id)
        {
            var victim = await _victimRepository.GetVictimByIdAsync(id);
            if (victim == null)
            {
                throw new KeyNotFoundException($"Victim with id {id} not found.");
            }
            return victim;
        }

        public async Task<Victim> UpdateVictimAsync(int id, VictimUpdateDto victimUpdateDto)
        {
            if (id != victimUpdateDto.Id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingVictim = await _victimRepository.GetVictimByIdAsync(id);
            if (existingVictim == null)
            {
                throw new KeyNotFoundException($"Victim with id {id} not found.");
            }
            var updatedVictim = victimUpdateDto.ToVictim();
            await _victimRepository.UpdateVictimAsync(updatedVictim);
            return updatedVictim;
        }

        public async Task DeleteVictimAsync(int id)
        {
            var existingVictim = await _victimRepository.GetVictimByIdAsync(id);
            if (existingVictim == null)
            {
                throw new KeyNotFoundException($"Victim with id {id} not found.");
            }
            
            await _victimRepository.DeleteVictimAsync(id);
        }

        public async Task<IEnumerable<Victim>> GetVictimAsync()
        {
            var victim = await _victimRepository.GetAllVictimAsync();
            if (victim == null)
            {
                throw new InvalidOperationException("Failed to retrieve victim.");
            }
            return victim;
        }
    }
}