using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using System.Data;

namespace LogicPersistence.Api.Repositories;

public class AffectedZoneRepository : IAffectedZoneRepository {
	private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

	public AffectedZoneRepository()
	{
		SqlMapper.AddTypeHandler(new HazardLevelTypeHandler());
	}

	public async Task<AffectedZone> CreateAffectedZoneAsync(AffectedZone affectedZone) {
		using var connection = new NpgsqlConnection(connectionString);
    
		// Create parameters manually
		var parameters = new DynamicParameters();
		parameters.Add("name", affectedZone.name);
		parameters.Add("description", affectedZone.description);
		parameters.Add("hazard_level", affectedZone.hazard_level.ToString());  // Convert enum to string
		parameters.Add("admin_id", affectedZone.admin_id);
    
		// Add explicit cast to hazard_level enum type
		const string sql = @"
			INSERT INTO affected_zone (name, description, hazard_level, admin_id)
			VALUES (@name, @description, @hazard_level::hazard_level, @admin_id)
			RETURNING *";

		return await connection.QuerySingleAsync<AffectedZone>(sql, parameters);
	}

	public async Task<bool> DeleteAffectedZoneAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM affected_zone WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
		return rowsAffected > 0;
	}

	public async Task<IEnumerable<AffectedZone>> GetAllAffectedZonesAsync() {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<AffectedZone>("SELECT * FROM affected_zone");
	}

	public async Task<AffectedZone?> GetAffectedZoneByIdAsync(int id) {
		using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<AffectedZone>("SELECT * FROM affected_zone where id = @id", new { id });
	}

	public async Task<AffectedZone> UpdateAffectedZoneAsync(AffectedZone affectedZone) {
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
            UPDATE affected_zone
            SET name = @name,
                description = @description,
                hazard_level = @hazard_level,
                admin_id = @admin_id,
            WHERE id = @id
            RETURNING *";

		return await connection.QuerySingleAsync<AffectedZone>(sql, affectedZone);
	}
}

#region HazardLevelTypeHandler

//sin esto, ningun método me funcionaba
public class HazardLevelTypeHandler : SqlMapper.TypeHandler<HazardLevel>
{
    public override HazardLevel Parse(object value)
    {
        return value switch
        {
            string str => Enum.Parse<HazardLevel>(str),
            int i => (HazardLevel)i,
            _ => HazardLevel.None
        };
    }

    public override void SetValue(IDbDataParameter parameter, HazardLevel value)
    {
        parameter.Value = value.ToString();
    }
}
#endregion
