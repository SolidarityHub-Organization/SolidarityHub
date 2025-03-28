using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class AbilityRepository : IAbilityRepository
{
    private readonly string _connectionString = "";
    private readonly IConfiguration _config;

    public AbilityRepository(IConfiguration config)
    {
        _config = config;
        string CONNECTION_STRING = $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};" +
                        $"Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};" +
                        $"Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};" +
                        $"Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};" +
                        $"Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}";
        _connectionString = CONNECTION_STRING;
    }
    
    public async Task<Ability> CreateAbilityAsync(Ability Ability)
    {
        using var connection = new NpgsqlConnection(_connectionString);
        var createdId = await connection.ExecuteScalarAsync<int>("INSERT INTO Ability (name, level) VALUES (@name, @level);select lastval();", Ability);
        Ability.Id = createdId;
        return Ability;
    }

    public async Task DeleteAbilityAsync(int id)
    {
        using var connection = new NpgsqlConnection(_connectionString);
        await connection.ExecuteAsync("DELETE FROM Ability WHERE id = @id", new { id });
    }

    public async Task<IEnumerable<Ability>> GetAllAbilityAsync()
    {
        using var connection = new NpgsqlConnection(_connectionString);
        return await connection.QueryAsync<Ability>("SELECT * FROM Ability");
    }

    public async Task<Ability?> GetAbilityByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Ability>("SELECT * FROM Ability where id = @id", new { id });
    }

    public async Task<Ability> UpdateAbilityAsync(Ability Ability)
    {
        using var connection = new NpgsqlConnection(_connectionString);
        await connection.ExecuteAsync("UPDATE Ability SET name = @name, level = @level WHERE id = @id", Ability);
        return Ability;
    }
}