namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using System.Data;

public class SkillRepository : ISkillRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    static SkillRepository()
    {
        NpgsqlConnection.GlobalTypeMapper.MapEnum<SkillLevel>("skill_level");
        SqlMapper.AddTypeHandler(new SkillLevelTypeHandler());
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

    public async Task<int> GetVolunteerCountById(int id, DateTime fromDate, DateTime toDate)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COALESCE(COUNT(v.id), 0)
            FROM skill s
            LEFT JOIN volunteer_skill vs ON s.id = vs.skill_id
            LEFT JOIN volunteer v ON vs.volunteer_id = v.id
            WHERE s.id = @id
            AND (v.created_at BETWEEN @fromDate AND @toDate OR v.id IS NULL)";

        return await connection.QuerySingleAsync<int>(sql, new { 
            id,
            fromDate,
            toDate
        });
    }
}

#region SkillLevelTypeHandler
//nose que cojones es esto pero cada vez que entramos en el proyecto no funcionan los métodos de skill
public class SkillLevelTypeHandler : SqlMapper.TypeHandler<SkillLevel>
{
    public override SkillLevel Parse(object value)
    {
        return value switch
        {
            string str => Enum.Parse<SkillLevel>(str),
            int i => (SkillLevel)i,
            _ => SkillLevel.Unknown
        };
    }

    public override void SetValue(IDbDataParameter parameter, SkillLevel value)
    {
        parameter.Value = value.ToString();
    }
}
#endregion