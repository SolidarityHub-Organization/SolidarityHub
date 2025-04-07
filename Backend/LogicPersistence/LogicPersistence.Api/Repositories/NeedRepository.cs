namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class NeedRepository : INeedRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

#region Needs
    public async Task<Need> CreateNeedAsync(Need need)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO need (name, description, urgency_level, victim_id, admin_id)
            VALUES (@name, @description, @urgencyLevel, @victim_id, @admin_id)
            RETURNING *";

        return await connection.QuerySingleAsync<Need>(sql, need);
    }

    public async Task<bool> DeleteNeedAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM need WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    } 

    public async Task<Need?> GetNeedByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<Need>("SELECT * FROM need WHERE id = @id", new { id });
    }

    public async Task<Need> UpdateNeedAsync(Need need)
    {
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

    public async Task<IEnumerable<Need>> GetAllNeedsAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Need>("SELECT * FROM need");
    }
#endregion
#region NeedType
    public async Task<NeedType> CreateNeedTypeAsync(NeedType needType)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO need_type (name, admin_id)
            VALUES (@name, @admin_id)
            RETURNING *";

        return await connection.QuerySingleAsync<NeedType>(sql, needType);
    }

    public async Task<bool> DeleteNeedTypeAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM need_type WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<NeedType?> GetNeedTypeByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<NeedType>("SELECT * FROM need_type WHERE id = @id", new { id });
    }

    public async Task<NeedType> UpdateNeedTypeAsync(NeedType needType)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE need_type
            SET name = @name, 
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<NeedType>(sql, needType);
    }
    public async Task<IEnumerable<NeedType>> GetAllNeedTypesAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<NeedType>("SELECT * FROM need_type");
    }

    public async Task<int> GetVictimCountById(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COUNT(n.victim_id)
            FROM need_type nt
            LEFT JOIN need_need_type nnt ON nt.id = nnt.need_type_id
            LEFT JOIN need n ON nnt.need_id = n.id
            WHERE nt.id = @id
            AND n.victym_id IS NOT NULL";

        return await connection.QuerySingleOrDefaultAsync<int>(sql, new { id });
    }
#endregion
}