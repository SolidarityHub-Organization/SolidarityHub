using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IAbilityServices
    {
        Task<Ability> CreateAbility(AbilityCreateDto AbilityCreateDto);
        Task<Ability> GetAbilityByIdAsync(int id);
        Task<Ability> UpdateAbilityAsync(int id, AbilityUpdateDto AbilityUpdateDto);
        Task DeleteAbilityAsync(int id);
        Task<IEnumerable<Ability>> GetPeopleAsync();
    }
}