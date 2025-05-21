namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using System.Data;
using System.Runtime.InteropServices;

public class NeedRepository : INeedRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	public NeedRepository() { }

	#region Needs
	public async Task<Need> CreateNeedAsync(Need need) {
		using var connection = new NpgsqlConnection(connectionString);
		await connection.OpenAsync();
		using var transaction = await connection.BeginTransactionAsync();

		try {
			const string insertNeedSql = @"
                INSERT INTO need (name, description, urgency_level, victim_id, admin_id)
                VALUES (@name, @description, 'Unknown', @victim_id, @admin_id)
				RETURNING * ";

			var createdNeed = await connection.QuerySingleAsync<Need>(
				insertNeedSql, need, transaction);

			const string insertRelationSql = @"
                INSERT INTO need_need_type (need_id, need_type_id)
                VALUES (@needId, @needTypeId)";

			await connection.ExecuteAsync(
				insertRelationSql,
				new { needId = createdNeed.id, needTypeId = need.need_type_id },
				transaction);
			createdNeed.need_type_id = need.need_type_id;

			await transaction.CommitAsync();
			return createdNeed;
		} catch {
			await transaction.RollbackAsync();
			throw;
		}
	}

	public async Task<bool> DeleteNeedAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM need WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
		return rowsAffected > 0;
	}

	public async Task<Need?> GetNeedByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<Need>("SELECT * FROM need WHERE id = @id", new { id });
	}

	public async Task<Need> UpdateNeedAsync(Need need) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE need
            SET name = @name,
                description = @description,
                urgency_level = @urgencyLevel,
                victim_id = @victim_id,
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *";

		return await connection.QuerySingleAsync<Need>(sql, need);
	}

	public async Task<IEnumerable<Need>> GetAllNeedsAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<Need>("SELECT * FROM need");
	}
	#endregion
	#region NeedType
	public async Task<NeedType> CreateNeedTypeAsync(NeedType needType) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            INSERT INTO need_type (name, admin_id)
            VALUES (@name, @admin_id)
            RETURNING *";

		return await connection.QuerySingleAsync<NeedType>(sql, needType);
	}

	public async Task<bool> DeleteNeedTypeAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM need_type WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
		return rowsAffected > 0;
	}

	public async Task<NeedType?> GetNeedTypeByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<NeedType>("SELECT * FROM need_type WHERE id = @id", new { id });
	}

	public async Task<Need?> GetNeedByVictimIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<Need>("SELECT * FROM need WHERE victim_id = @id", new { id });
	}

	public async Task<NeedType> UpdateNeedTypeAsync(NeedType needType) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE need_type
            SET name = @name,
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *";

		return await connection.QuerySingleAsync<NeedType>(sql, needType);
	}
	public async Task<IEnumerable<NeedType>> GetAllNeedTypesAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<NeedType>("SELECT * FROM need_type");
	}

	//este método se podrá borrar en un futuro
	public async Task<int> GetVictimCountById(int id) {


		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            SELECT COUNT(DISTINCT n.victim_id)
            FROM need_type nt
            LEFT JOIN need_need_type nnt ON nt.id = nnt.need_type_id
            LEFT JOIN need n ON nnt.need_id = n.id
            WHERE nt.id = @id
            AND n.victim_id IS NOT NULL";
		return await connection.QuerySingleOrDefaultAsync<int>(sql, new { id });
	}

	public async Task<int> GetVictimCountByIdFilteredByDate(int id, DateTime startDate, DateTime endDate) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            SELECT COUNT(DISTINCT n.victim_id)
            FROM need_type nt
            LEFT JOIN need_need_type nnt ON nt.id = nnt.need_type_id
            LEFT JOIN need n ON nnt.need_id = n.id
            WHERE nt.id = @id
            AND n.victim_id IS NOT NULL
            AND n.created_at BETWEEN @startDate AND @endDate";
		return await connection.QuerySingleOrDefaultAsync<int>(sql, new { id, startDate, endDate });
	}
	#endregion
}
