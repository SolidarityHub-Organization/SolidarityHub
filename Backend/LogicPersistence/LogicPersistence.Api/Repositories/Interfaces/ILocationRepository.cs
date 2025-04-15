using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces;

public interface ILocationRepository {
	Task<Location> CreateLocationAsync(Location location);
	Task<Location> UpdateLocationAsync(Location location);
	Task<bool> DeleteLocationAsync(int id);
	Task<Location?> GetLocationByIdAsync(int id);
	Task<IEnumerable<Location>> GetAllLocationsAsync();
	Task<IEnumerable<Location>> GetLocationsByAffectedZoneIdAsync(int id);
}
