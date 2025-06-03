using LogicPersistence.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Services {
	public class GeneralServices : IGeneralServices {
		private readonly IGeneralRepository _generalRepository;

		public GeneralServices(IGeneralRepository generalRepository) {
			_generalRepository = generalRepository;
		}

		public async Task PopulateDatabaseAsync() {
			var general = await _generalRepository.PopulateDatabaseAsync();
			if (!general) {
				throw new InvalidOperationException("Failed to populate database.");
			}
		}

		public async Task ClearDatabaseAsync() {
			var general = await _generalRepository.ClearDatabaseAsync();
			if (!general) {
				throw new InvalidOperationException("Failed to clear database.");
			}
		}

		public async Task SuperPopulateDatabaseAsync() {
			var general = await _generalRepository.SuperPopulateDatabaseAsync();
			if (!general) {
				throw new InvalidOperationException("Failed to super populate database.");
			}
		}

		public static void ValidateDates(DateTime fromDate, DateTime toDate) {
			if (fromDate > toDate) {
				throw new ArgumentException("La fecha de inicio debe ser menor o igual que la fecha de finalización.");
			}
			if (fromDate < DateTime.MinValue || toDate > DateTime.MaxValue) {
				throw new ArgumentOutOfRangeException("Las fechas están fuera del rango válido.");
			}
		}
	}
}
