using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories.Interfaces;

public interface ILocationRepository {
	Task<Location> CreateLocationAsync(Location location);
	Task<Location> UpdateLocationAsync(Location location);
	Task<bool> DeleteLocationAsync(int id);
	Task<Location?> GetLocationByIdAsync(int id);
	Task<IEnumerable<Location>> GetAllLocationsAsync();
	Task<IEnumerable<Location>> GetLocationsByAffectedZoneIdAsync(int id);
	Task<IEnumerable<AffectedZone>> GetAffectedZoneByLocationIdAsync(int id);
	Task<bool> CreateLocationsByAffectedZoneIdAsync(int affectedZoneId, IEnumerable<Location> locations);
	Task<bool> DeleteLocationsByAffectedZoneIdAsync(int affectedZoneId);
}
