using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class AffectedZoneRepository : IAffectedZoneRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	public async Task<AffectedZone> CreateAffectedZoneAsync(AffectedZone affectedZone) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            INSERT INTO affected_zone (name, description, hazard_level, admin_id)
            VALUES (@name, @description, @hazard_level, @admin_id)
            RETURNING *";

		return await connection.QuerySingleAsync<AffectedZone>(sql, affectedZone);
	}

	public async Task<bool> DeleteAffectedZoneAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM affected_zone WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
		return rowsAffected > 0;
	}

	public async Task<IEnumerable<AffectedZone>> GetAllAffectedZonesAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<AffectedZone>("SELECT * FROM affected_zone");
	}

	public async Task<AffectedZone?> GetAffectedZoneByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<AffectedZone>("SELECT * FROM affected_zone where id = @id", new { id });
	}

	public async Task<AffectedZone> UpdateAffectedZoneAsync(AffectedZone affectedZone) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE affected_zone
            SET name = @name,
                description = @description,
                hazard_level = @hazard_level,
                admin_id = @admin_id,
            WHERE id = @id
            RETURNING *";

		return await connection.QuerySingleAsync<AffectedZone>(sql, affectedZone);
	}
}
