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
	}
}
