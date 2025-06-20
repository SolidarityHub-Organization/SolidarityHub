using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services.Interfaces;

namespace LogicPersistence.Api.Services {
	public class LocationServices : ILocationServices {
		private readonly ILocationRepository _locationRepository;
		private readonly IPaginationService _paginationService;
		private readonly IAffectedZoneRepository _affectedZoneRepository;

		public LocationServices(ILocationRepository locationRepository, 
                       IPaginationService paginationService,
                       IAffectedZoneRepository affectedZoneRepository) 
		{
			_locationRepository = locationRepository;
			_paginationService = paginationService;
			_affectedZoneRepository = affectedZoneRepository;
		}


		public async Task<Models.Location> CreateLocationAsync(LocationCreateDto locationCreateDto) {
			if (locationCreateDto == null) {
				throw new ArgumentNullException(nameof(locationCreateDto));
			}

			var location = await _locationRepository.CreateLocationAsync(locationCreateDto.ToLocation());
			if (location == null) {
				throw new InvalidOperationException("Failed to create location.");
			}

			return location;
		}

		public async Task<Location> GetLocationByIdAsync(int id) {
			var location = await _locationRepository.GetLocationByIdAsync(id);
			if (location == null) {
				throw new KeyNotFoundException($"Location with id {id} not found.");
			}
			return location;
		}

		public async Task<Location> UpdateLocationAsync(int id, LocationUpdateDto locationUpdateDto) {
			if (id != locationUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}
			var existingLocation = await _locationRepository.GetLocationByIdAsync(id);
			if (existingLocation == null) {
				throw new KeyNotFoundException($"Location with id {id} not found.");
			}
			var updatedLocation = locationUpdateDto.ToLocation();
			await _locationRepository.UpdateLocationAsync(updatedLocation);
			return updatedLocation;
		}

		public async System.Threading.Tasks.Task DeleteLocationAsync(int id) {
			var existingLocation = await _locationRepository.GetLocationByIdAsync(id);
			if (existingLocation == null) {
				throw new KeyNotFoundException($"Location with id {id} not found.");
			}

			var deletionSuccesful = await _locationRepository.DeleteLocationAsync(id);
			if (!deletionSuccesful) {
				throw new InvalidOperationException($"Failed to delete location with id {id}.");
			}
		}

		public async Task<IEnumerable<Location>> GetAllLocationsAsync() {
			var locations = await _locationRepository.GetAllLocationsAsync();
			if (locations == null) {
				throw new InvalidOperationException("Failed to retrieve locations.");
			}
			return locations;
		}
		public async Task<IEnumerable<AffectedZone>> GetAffectedZoneByLocationIdAsync(int id) {
			var locations = await _locationRepository.GetAffectedZoneByLocationIdAsync(id);
			if (locations == null) {
				throw new InvalidOperationException("Failed to retrieve locations.");
			}
			return locations;
		}

		public async Task<(IEnumerable<Location> Locations, int TotalCount)> GetPaginatedLocationsAsync(int pageNumber, int pageSize) {
			return await _paginationService.GetPaginatedAsync<Location>(pageNumber, pageSize, "location", "created_at DESC, id DESC");
		}

        public async Task<bool> CreateLocationsByAffectedZoneIdAsync(int affectedZoneId, IEnumerable<Location> locations)
        {
            return await _locationRepository.CreateLocationsByAffectedZoneIdAsync(affectedZoneId, locations);
        }

        public async Task<bool> DeleteLocationsByAffectedZoneIdAsync(int affectedZoneId)
        {
            try
            {
                // Check if affected zone exists using the correct repository
                var affectedZone = await _affectedZoneRepository.GetAffectedZoneByIdAsync(affectedZoneId);
                if (affectedZone == null)
                {
                    throw new KeyNotFoundException($"Affected zone with id {affectedZoneId} not found.");
                }

                // Call the repository method to delete the locations
                var deletionSuccessful = await _locationRepository.DeleteLocationsByAffectedZoneIdAsync(affectedZoneId);
                
                if (!deletionSuccessful)
                {
                    throw new InvalidOperationException($"Failed to delete locations for affected zone with id {affectedZoneId}.");
                }
                
                return true;
            }
            catch (KeyNotFoundException)
            {
                // Rethrow
                throw;
            }
            catch (Exception ex)
            {
                // Log the exception
                Console.WriteLine($"Error in DeleteLocationsByAffectedZoneIdAsync: {ex.Message}");
                throw new InvalidOperationException($"Failed to delete locations for affected zone with id {affectedZoneId}.", ex);
            }
        }
    }
}
