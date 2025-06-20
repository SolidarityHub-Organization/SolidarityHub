using Dapper;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Repositories.Interfaces;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class LocationRepository : ILocationRepository {
	private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

	public async Task<Location> CreateLocationAsync(Location location) {
		using var connection = new NpgsqlConnection(connectionString);

		const string selectSql = @"
		SELECT * FROM location
		WHERE latitude = @latitude AND longitude = @longitude";

		var existing = await connection.QuerySingleOrDefaultAsync<Location>(selectSql, location);

		if (existing is not null)
			return existing;

		const string insertSql = @"
		INSERT INTO location (latitude, longitude, victim_id, volunteer_id)
		VALUES (@latitude, @longitude, @victim_id, @volunteer_id)
		RETURNING *";

		return await connection.QuerySingleAsync<Location>(insertSql, location);
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

	public async Task<IEnumerable<Location>> GetLocationsByAffectedZoneIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
			SELECT l.* 
			FROM location l
			INNER JOIN affected_zone_location azl ON l.id = azl.location_id
			WHERE azl.affected_zone_id = @id
			ORDER BY l.created_at ASC";

		return await connection.QueryAsync<Location>(sql, new { id });

	}

	public async Task<IEnumerable<AffectedZone>> GetAffectedZoneByLocationIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
		SELECT az.*
		FROM location L
		join affected_zone_location azl on azl.location_id = L.id
		JOIN affected_zone az ON azl.affected_zone_id = az.id
		WHERE L.id = @id";

		return await connection.QueryAsync<AffectedZone>(sql, new { id });

	}

	public async Task<bool> CreateLocationsByAffectedZoneIdAsync(int affectedZoneId, IEnumerable<Location> locations)
	{
		using var connection = new NpgsqlConnection(connectionString);
		
		// Explicitly open the connection
		await connection.OpenAsync();
		
		using var transaction = await connection.BeginTransactionAsync();

		try
		{
			// Get current timestamp as base
			var baseTime = DateTime.UtcNow;
			int i = 0;
			
			foreach (var location in locations)
			{
				const string insertLocationSql = @"
					INSERT INTO location (latitude, longitude, created_at)
					VALUES (@latitude, @longitude, @created_at)
					RETURNING id";
				
				// Increment timestamp by 1 second for each point to preserve order
				var pointTime = baseTime.AddSeconds(i++);
				
				var locationId = await connection.ExecuteScalarAsync<int>(
					insertLocationSql, 
					new { 
						location.latitude, 
						location.longitude, 
						created_at = pointTime
					}, 
					transaction);

				const string insertLinkSql = @"
					INSERT INTO affected_zone_location (affected_zone_id, location_id)
					VALUES (@affectedZoneId, @locationId)";
				await connection.ExecuteAsync(insertLinkSql, new { affectedZoneId, locationId }, transaction);
			}

			await transaction.CommitAsync();
			return true;
		}
		catch (Exception ex)
		{
			await transaction.RollbackAsync();
			Console.WriteLine($"Error in CreateLocationsByAffectedZoneIdAsync: {ex.Message}");
			throw;
		}
	}

	public async Task<bool> DeleteLocationsByAffectedZoneIdAsync(int affectedZoneId)
	{
		using var connection = new NpgsqlConnection(connectionString);
		
		// Explicitly open the connection
		await connection.OpenAsync();
		
		using var transaction = await connection.BeginTransactionAsync();

		try
		{
			// First get all associated location IDs
			const string getLocationIdsSql = @"
				SELECT location_id 
				FROM affected_zone_location
				WHERE affected_zone_id = @affectedZoneId";
				
			var locationIds = await connection.QueryAsync<int>(getLocationIdsSql, new { affectedZoneId }, transaction);
			
			// Delete the links in the junction table
			const string deleteLinksSql = @"
				DELETE FROM affected_zone_location
				WHERE affected_zone_id = @affectedZoneId";
				
			await connection.ExecuteAsync(deleteLinksSql, new { affectedZoneId }, transaction);
			
			// Delete the actual locations
			if (locationIds.Any())
			{
				const string deleteLocationsSql = @"
					DELETE FROM location
					WHERE id = ANY(@locationIds)";
					
				await connection.ExecuteAsync(deleteLocationsSql, new { locationIds = locationIds.ToArray() }, transaction);
			}

			await transaction.CommitAsync();
			return true;
		}
		catch (Exception ex)
		{
			await transaction.RollbackAsync();
			Console.WriteLine($"Error in DeleteLocationsByAffectedZoneIdAsync: {ex.Message}");
			throw;
		}
	}
}
