namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IVictimRepository {
    Task<Victim> CreateVictimAsync(Victim victim);
    Task<Victim> UpdateVictimAsync(Victim victim);
    Task DeleteVictimAsync(int id);
    Task<IEnumerable<Victim>> GetAllVictimsAsync();
    Task<Victim?> GetVictimByIdAsync(int id);
}