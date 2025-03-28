using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class VictimRepository : IVictimRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Victim> CreateVictim(Victim verson)
    {
        using var connection = new NpgsqlConnection(connectionString);
        var newVictim = await connection.ExecuteScalarAsync<int>("INSERT INTO victim (email, password, name, surname, prefix, phone, address, dni) VALUES (@email, @password, @name, @surname, @prefix, @phone, @address, @dni); select lastval();", victim);
        return newVictim;
    }

    public async Task DeleteVictim(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.ExecuteAsync("DELETE FROM victim WHERE id = @id", new { id });
    }

    public async Task<IEnumerable<Victim>> GetAllVictims()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Victim>("SELECT * FROM victim");
    }

    public async Task<Victim?> GetVictimByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<Victim>("SELECT * FROM victim where id = @id", new { id });
    }

    public async Task<Victim> UpdateVictim(Victim victim)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.ExecuteAsync("UPDATE victim SET email = @email, password = @password, name = @name, surname = @surname, prefix = @prefix, phone = @phone, address = @address, dni = @dni,  WHERE id = @id", victim);
        return victim;
    }
}