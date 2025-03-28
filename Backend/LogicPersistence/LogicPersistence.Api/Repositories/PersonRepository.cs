using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class PersonRepository : IPersonRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Person> CreatePersonAsync(Person person)
    {
        using var connection = new NpgsqlConnection(connectionString);
        var createdId = await connection.ExecuteScalarAsync<int>("INSERT INTO person (name, email) VALUES (@name, @email);select lastval();", person);
        person.id = createdId;
        return person;
    }

    public async Task DeletePersonAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.ExecuteAsync("DELETE FROM person WHERE id = @id", new { id });
    }

    public async Task<IEnumerable<Person>> GetAllPersonAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Person>("SELECT * FROM person");
    }

    public async Task<Person?> GetPersonByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<Person>("SELECT * FROM person where id = @id", new { id });
    }

    public async Task<Person> UpdatePersonAsync(Person person)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.ExecuteAsync("UPDATE person SET name = @name, email = @email WHERE id = @id", person);
        return person;
    }
}