using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class VictimRepository : IVictimRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

	public async Task<Victim> CreateVictimAsync(Victim victim) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            INSERT INTO victim (email, password, name, surname, prefix, phone, address, identification, location_id) 
            VALUES (@email, @password, @name, @surname, @prefix, @phone, @address, @identification, @location_id)
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

	public async Task<Victim> UpdateVictimAsync(Victim victim) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE victim 
            SET email = @email, 
                password = @password, 
                name = @name, 
                surname = @surname, 
                prefix = @prefix, 
                phone = @phone, 
                address = @address, 
                identification = @identification,
				location_id = @location_id
            WHERE id = @id
            RETURNING *";
		
		return await connection.QuerySingleAsync<Victim>(sql, victim);
	}
}
