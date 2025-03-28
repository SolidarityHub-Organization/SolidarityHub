namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IAbilityRepository {
    Task<Ability> CreateAbilityAsync(Ability Ability);
    Task<Ability> UpdateAbilityAsync(Ability Ability);
    Task DeleteAbilityAsync(int id);
    Task<IEnumerable<Ability>> GetAllAbilityAsync();
    Task<Ability?> GetAbilityByIdAsync(int id);
}