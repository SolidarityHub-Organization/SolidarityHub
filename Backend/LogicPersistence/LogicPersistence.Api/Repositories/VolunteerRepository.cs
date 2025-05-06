namespace LogicPersistence.Api.Repositories;
using Dapper;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using Newtonsoft.Json;
using Npgsql;

public class VolunteerRepository : IVolunteerRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Volunteer> CreateVolunteerAsync(Volunteer volunteer)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO volunteer (email, password, name, surname, prefix, phone_number, address, identification, location_id)
            VALUES (@email, @password, @name, @surname, @prefix, @phone_number, @address, @identification, @location_id)
            RETURNING *";  // Return all columns instead of just id

        return await connection.QuerySingleAsync<Volunteer>(sql, volunteer);  // Get the complete record back with QuerySingleAsync (works with RETURNING *)
    }

    public async Task<Volunteer> UpdateVolunteerAsync(Volunteer volunteer)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE volunteer
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

        return await connection.QuerySingleAsync<Volunteer>(sql, volunteer);
    }

    public async Task<bool> DeleteVolunteerAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM volunteer WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<Volunteer>> GetAllVolunteersAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteer";

        return await connection.QueryAsync<Volunteer>(sql);
    }

    public async Task<IEnumerable<VolunteerWithDetailsDisplayDto>> GetAllVolunteersWithDetailsAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
        WITH volunteer_skills AS (
            SELECT
                v.id as volunteer_id,
                json_agg(
                    json_build_object(
                        'id', s.id,
                        'name', s.name,
                        'level', s.level,
                        'admin_id', s.admin_id
                    )
                ) FILTER (WHERE s.id IS NOT NULL) AS skills
            FROM
                volunteer v
            LEFT JOIN
                volunteer_skill vs ON v.id = vs.volunteer_id
            LEFT JOIN
                skill s ON vs.skill_id = s.id
            GROUP BY
                v.id
        )
        SELECT
            v.id,
            v.email,
            v.name,
            v.surname,
            v.prefix,
            v.phone_number,
            v.address,
            v.identification,
            v.created_at,
            v.location_id,
            COALESCE(vs.skills, '[]') as skills_json
        FROM
            volunteer v
        LEFT JOIN
            volunteer_skills vs ON v.id = vs.volunteer_id
        ";

        var volunteers = await connection.QueryAsync<VolunteerWithDetailsDisplayDto>(sql);

        foreach (var volunteer in volunteers)
        {
            volunteer.skills = JsonConvert.DeserializeObject<IEnumerable<SkillDisplayDto>>(volunteer.skillsJson) ?? [];
            volunteer.skillsJson = "";
        }

        return volunteers;
    }

    public async Task<Volunteer?> GetVolunteerByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteer WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<Volunteer>(sql, new { id });
    }

    public async Task<Volunteer?> GetVolunteerByEmailAsync(string email)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM volunteer WHERE email = @email";

        return await connection.QuerySingleOrDefaultAsync<Volunteer>(sql, new { email });
    }
}
