namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IVictimRepository {
	Task<Victim> CreateVictimAsync(Victim victim);
	Task<Victim> UpdateVictimAsync(Victim victim);
	Task<bool> DeleteVictimAsync(int id);
	Task<IEnumerable<Victim>> GetAllVictimsAsync();
	Task<Victim?> GetVictimByIdAsync(int id);
	Task<Victim?> GetVictimByEmailAsync(string email);
	Task<UrgencyLevel> GetVictimMaxUrgencyLevelByIdAsync(int victimId);
}
