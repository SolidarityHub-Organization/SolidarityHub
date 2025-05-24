using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Services {
	public interface IGeneralServices {
		Task PopulateDatabaseAsync();
		Task ClearDatabaseAsync();
		Task SuperPopulateDatabaseAsync();

	}
}
