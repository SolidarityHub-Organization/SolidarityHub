using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;


// The services are the classes that contain the business logic of the application. They are responsible for processing the data and performing the necessary operations to fulfill the requests from the client passed from the controllers.
// It must be attached to the repository to be able to perform the necessary operations on the database.

namespace LogicPersistence.Api.Services {
	public class VictimServices : IVictimServices {
		private readonly IVictimRepository _victimRepository;

		public VictimServices(IVictimRepository victimRepository, ILocationRepository locationRepository) {
			_victimRepository = victimRepository;
		}


		public async Task<Victim> CreateVictimAsync(VictimCreateDto victimCreateDto) {
			if (victimCreateDto == null) {
				throw new ArgumentNullException(nameof(victimCreateDto));
			}

			var victim = await _victimRepository.CreateVictimAsync(victimCreateDto.ToVictim());
			if (victim == null) {
				throw new InvalidOperationException("Failed to create victim.");
			}

			return victim;
		}

		public async Task<Victim> GetVictimByIdAsync(int id) {
			var victim = await _victimRepository.GetVictimByIdAsync(id);
			if (victim == null) {
				throw new KeyNotFoundException($"Victim with id {id} not found.");
			}
			return victim;
		}

		public async Task<Victim> UpdateVictimAsync(int id, VictimUpdateDto victimUpdateDto) {
			if (id != victimUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}
			var existingVictim = await _victimRepository.GetVictimByIdAsync(id);
			if (existingVictim == null) {
				throw new KeyNotFoundException($"Victim with id {id} not found.");
			}
			var updatedVictim = victimUpdateDto.ToVictim();
			await _victimRepository.UpdateVictimAsync(updatedVictim);
			return updatedVictim;
		}

		public async System.Threading.Tasks.Task DeleteVictimAsync(int id) {
			var existingVictim = await _victimRepository.GetVictimByIdAsync(id);
			if (existingVictim == null) {
				throw new KeyNotFoundException($"Victim with id {id} not found.");
			}

			var deletionSuccesful = await _victimRepository.DeleteVictimAsync(id);
            if (!deletionSuccesful) 
            {
                throw new InvalidOperationException($"Failed to delete victim with id {id}.");
            }
		}

		public async Task<IEnumerable<Victim>> GetAllVictimsAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			return victims;
		}

		public async Task<int> GetVictimsCountAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			return victims.Count();
		}

		public async Task<IEnumerable<(string date, int count)>> GetVictimsCountByDateAsync() {
			var victims = await _victimRepository.GetAllVictimsAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve victims.");
			}
			var oldestDate = victims.Min(v => v.created_at).Date;
			var days = (DateTime.Now.Date - oldestDate).Days + 1;
			var victimsCountByDate = Enumerable.Range(0, days)
				.Select(d => oldestDate.AddDays(d)) //esto crea una lista de fechas desde primera hasta hoy
				.Select(d => new { Date = d, Count = victims.Count(v => v.created_at.Date == d) }) //aqui coge las fechas y añade el numero de afectados
				.ToList();

			return victimsCountByDate.Select(v => (v.Date.ToString("dd-MM-yyyy"), v.Count)).ToList();
		}

		
	}
}
