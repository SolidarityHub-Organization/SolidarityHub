namespace LogicPersistence.Api.Repositories;

public interface IGeneralRepository {
	public Task<bool> PopulateDatabaseAsync();
	public Task<bool> ClearDatabaseAsync();
}
