using Dapper;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Repositories.Interfaces;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class LocationRepository : ILocationRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	public async Task<Location> CreateLocationAsync(Location location) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            INSERT INTO location (latitude, longitude, victim_id, volunteer_id)
            VALUES (@latitude, @longitude, @victim_id, @volunteer_id)
            RETURNING *";

		return await connection.QuerySingleAsync<Location>(sql, location);
	}

	public async Task<bool> DeleteLocationAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM location WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
		return rowsAffected > 0;
	}

	public async Task<Location?> GetLocationByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<Location>("SELECT * FROM location WHERE id = @id", new { id });
	}

	public async Task<Location> UpdateLocationAsync(Location location) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE location
            SET latitude = @latitude,
                longitude = @longitude,
                victim_id = @victim_id,
                volunteer_id = @volunteer_id
            WHERE id = @id
            RETURNING *";

		return await connection.QuerySingleAsync<Location>(sql, location);
	}

	public async Task<IEnumerable<Location>> GetAllLocationsAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<Location>("SELECT * FROM location");
	}
}
