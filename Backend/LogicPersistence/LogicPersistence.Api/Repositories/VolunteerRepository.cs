namespace LogicPersistence.Api.Repositories;

using System.Data;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class VolunteerRepository : IVolunteerRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Volunteer> CreateVolunteerAsync(Volunteer volunteer)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO volunteers (email, password, name, surname, prefix, phone_number, address, identification, time_preference_id)
            VALUES (@email, @password, @name, @surname, @prefix, @phone_number, @address, @identification, @time_preference_id)
            RETURNING *";  // Return all columns instead of just id

        return await connection.QuerySingleAsync<Volunteer>(sql, volunteer);  // Get the complete record back with QuerySingleAsync
    }

    public async Task<Volunteer> UpdateVolunteerAsync(Volunteer volunteer)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE volunteers 
            SET email = @email,
                password = @password,
                name = @name,
                surname = @surname,
                prefix = @prefix,
                phone_number = @phone_number,
                address = @address,
                identification = @identification,
                time_preference_id = @time_preference_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<Volunteer>(sql, volunteer);
    }

    public async Task<bool> DeleteVolunteerAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM volunteers WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<Volunteer>> GetAllVolunteersAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteers";

        return await connection.QueryAsync<Volunteer>(sql);
    }

    public async Task<Volunteer?> GetVolunteerByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteers WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<Volunteer>(sql, new { id });
    }

    public async Task<Volunteer?> GetVolunteerByEmailAsync(string email)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteers WHERE email = @email";

        return await connection.QuerySingleOrDefaultAsync<Volunteer>(sql, new { email });
    }
}