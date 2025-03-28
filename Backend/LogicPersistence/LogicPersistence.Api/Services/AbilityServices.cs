using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;


// The services are the classes that contain the business logic of the application. They are responsible for processing the data and performing the necessary operations to fulfill the requests from the client passed from the controllers.
// It must be attached to the repository to be able to perform the necessary operations on the database.

namespace LogicPersistence.Api.Services
{
    public class 
        
        Services : IAbilityServices
    {
        private readonly IAbilityRepository _AbilityRepository;

        public AbilityServices(IAbilityRepository AbilityRepository)
        {
            _AbilityRepository = AbilityRepository;
        }


        public async Task<Ability> CreateAbility(AbilityCreateDto AbilityCreateDto)
        {
            if (AbilityCreateDto == null)
            {
                throw new ArgumentNullException(nameof(AbilityCreateDto));
            }
            
            var Ability = await _AbilityRepository.CreateAbilityAsync(AbilityCreateDto.ToAbility());
            if (Ability == null)
            {
                throw new InvalidOperationException("Failed to create Ability.");
            }

            return Ability;
        }

        public async Task<Ability> GetAbilityByIdAsync(int id)
        {
            var Ability = await _AbilityRepository.GetAbilityByIdAsync(id);
            if (Ability == null)
            {
                throw new KeyNotFoundException($"Ability with id {id} not found.");
            }
            return Ability;
        }

        public async Task<Ability> UpdateAbilityAsync(int id, AbilityUpdateDto AbilityUpdateDto)
        {
            if (id != AbilityUpdateDto.Id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingAbility = await _AbilityRepository.GetAbilityByIdAsync(id);
            if (existingAbility == null)
            {
                throw new KeyNotFoundException($"Ability with id {id} not found.");
            }
            var updatedAbility = AbilityUpdateDto.ToAbility();
            await _AbilityRepository.UpdateAbilityAsync(updatedAbility);
            return updatedAbility;
        }

        public async Task DeleteAbilityAsync(int id)
        {
            var existingAbility = await _AbilityRepository.GetAbilityByIdAsync(id);
            if (existingAbility == null)
            {
                throw new KeyNotFoundException($"Ability with id {id} not found.");
            }
            
            await _AbilityRepository.DeleteAbilityAsync(id);
        }

        public async Task<IEnumerable<Ability>> GetPeopleAsync()
        {
            var people = await _AbilityRepository.GetAllAbilityAsync();
            if (people == null)
            {
                throw new InvalidOperationException("Failed to retrieve people.");
            }
            return people;
        }
    }
}