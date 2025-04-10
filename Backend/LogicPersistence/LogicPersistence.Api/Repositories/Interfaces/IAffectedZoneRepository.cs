namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IAffectedZoneRepository {
	Task<AffectedZone> CreateAffectedZoneAsync(AffectedZone affectedZone);
	Task<AffectedZone> UpdateAffectedZoneAsync(AffectedZone affectedZone);
	Task<bool> DeleteAffectedZoneAsync(int id);
	Task<IEnumerable<AffectedZone>> GetAllAffectedZonesAsync();
	Task<AffectedZone?> GetAffectedZoneByIdAsync(int id);
}
