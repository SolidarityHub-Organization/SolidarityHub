using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services {
	public interface ILocationServices {
		Task<Models.Location> CreateLocationAsync(LocationCreateDto LocationCreateDto);
		Task<Models.Location> GetLocationByIdAsync(int id);
		Task<Models.Location> UpdateLocationAsync(int id, LocationUpdateDto LocationUpdateDto);
		System.Threading.Tasks.Task DeleteLocationAsync(int id);
		Task<IEnumerable<Location>> GetAllLocationsAsync();
		Task<IEnumerable<AffectedZone>> GetAffectedZoneByLocationIdAsync(int id);
		Task<(IEnumerable<Location> Locations, int TotalCount)> GetPaginatedLocationsAsync(int pageNumber, int pageSize);
		Task<bool> CreateLocationsByAffectedZoneIdAsync(int affectedZoneId, IEnumerable<Location> locations);
		Task<bool> DeleteLocationsByAffectedZoneIdAsync(int affectedZoneId);
		}
	}
