using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class VictimRepository : IVictimRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	public async Task<Victim> CreateVictimAsync(Victim victim) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            INSERT INTO victim (email, password, name, surname, prefix, phone_number, address, identification, location_id) 
            VALUES (@email, @password, @name, @surname, @prefix, @phone_number, @address, @identification, @location_id)
            RETURNING *";
		
		return await connection.QuerySingleAsync<Victim>(sql, victim);
	}

	public async Task<bool> DeleteVictimAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM victim WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
	}

	public async Task<IEnumerable<Victim>> GetAllVictimsAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<Victim>("SELECT * FROM victim");
	}

	public async Task<Victim?> GetVictimByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<Victim>("SELECT * FROM victim where id = @id", new { id });
	}

	public async Task<Victim?> GetVictimByEmailAsync(string email) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "SELECT * FROM victim WHERE email = @email";

		return await connection.QuerySingleOrDefaultAsync<Victim>(sql, new { email });
		
	}
		public async Task<Victim> UpdateVictimAsync(Victim victim) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE victim 
            SET email = @email, 
                password = @password, 
                name = @name, 
                surname = @surname, 
                prefix = @prefix, 
                phone_number = @phone_number, 
                address = @address, 
                identification = @identification,
				location_id = @location_id
            WHERE id = @id
            RETURNING *";
		
		return await connection.QuerySingleAsync<Victim>(sql, victim);
	}

	public async Task<UrgencyLevel> GetVictimMaxUrgencyLevelByIdAsync(int victimId)
	{
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
			SELECT COALESCE(MAX(n.urgency_level::text), 'Unknown')
			FROM victim v
			LEFT JOIN need n ON v.id = n.victim_id
			WHERE v.id = @victimId";

		var result = await connection.QuerySingleOrDefaultAsync<string>(sql, new { victimId });
		return Enum.Parse<UrgencyLevel>(result);
    }
}
