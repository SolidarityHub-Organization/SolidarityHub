namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class SkillRepository : ISkillRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    static SkillRepository()
    {
        NpgsqlConnection.GlobalTypeMapper.MapEnum<SkillLevel>("skill_level");
    }

    public async Task<Skill> CreateSkillAsync(Skill skill)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @" 
            INSERT INTO skill (name, level, admin_id)
            VALUES (@name, @level, @admin_id)
            RETURNING *";

        return await connection.QuerySingleAsync<Skill>(sql, skill);
    }

    public async Task<bool> DeleteSkillAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM skill WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<Skill?> GetSkillByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<Skill>("SELECT * FROM skill WHERE id = @id", new { id });
    }

    public async Task<Skill> UpdateSkillAsync(Skill skill)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE skill
            SET name = @name, 
                level = @level,
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<Skill>(sql, skill);
    }

    public async Task<IEnumerable<Skill>> GetAllSkillsAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Skill>("SELECT * FROM skill");
    }

    public async Task<int> GetVolunteerCountById(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COUNT(vs.volunteer_id) 
            FROM skill s
            LEFT JOIN volunteer_skill vs ON s.id = vs.skill_id
            WHERE s.id = @id
            GROUP BY s.id";

        return await connection.QuerySingleOrDefaultAsync<int>(sql, new { id });
    }
}