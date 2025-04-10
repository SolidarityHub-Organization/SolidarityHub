namespace LogicPersistence.Api.Repositories;

using Npgsql;

public class GeneralRepository : IGeneralRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	#region General
	public async Task<bool> PopulateDatabaseAsync() {
		try {
			using var connection = new NpgsqlConnection(connectionString);
			await connection.OpenAsync();

			string projectDirectory = AppContext.BaseDirectory;
			while (!Directory.Exists(Path.Combine(projectDirectory, "Migrations"))) {
				DirectoryInfo? parent = Directory.GetParent(projectDirectory);
				if (parent == null) {
					break;
				}
				projectDirectory = parent.FullName;
			}
			string scriptPath = Path.Combine(projectDirectory, "Migrations", "SQL", "PopulateTables.sql");

			string sqlScript = await File.ReadAllTextAsync(scriptPath);

			using var command = new NpgsqlCommand(sqlScript, connection);
			await command.ExecuteNonQueryAsync();

			return true;
		} catch (Exception ex) {
			Console.WriteLine($"Error populating database: {ex.Message}");
			return false;
		}
	}

	public async Task<bool> ClearDatabaseAsync() {
		try {
			using var connection = new NpgsqlConnection(connectionString);
			await connection.OpenAsync();

			string projectDirectory = AppContext.BaseDirectory;
			while (!Directory.Exists(Path.Combine(projectDirectory, "Migrations"))) {
				DirectoryInfo? parent = Directory.GetParent(projectDirectory);
				if (parent == null) {
					break;
				}
				projectDirectory = parent.FullName;
			}
			string scriptPath = Path.Combine(projectDirectory, "Migrations", "SQL", "ClearTables.sql");

			string sqlScript = await File.ReadAllTextAsync(scriptPath);

			using var command = new NpgsqlCommand(sqlScript, connection);
			await command.ExecuteNonQueryAsync();

			return true;
		} catch (Exception ex) {
			Console.WriteLine($"Error clearing database: {ex.Message}");
			return false;
		}
	}
	#endregion
}
