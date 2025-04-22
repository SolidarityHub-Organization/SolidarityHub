using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services {
	public class LocationServices : ILocationServices {
		private readonly ILocationRepository _locationRepository;

		public LocationServices(ILocationRepository locationRepository) {
			_locationRepository = locationRepository;
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
	}
}
