using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Repositories.Interfaces;
using System.Data;

namespace LogicPersistence.Api.Repositories;

public class PointRepository : IPointRepository {
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();


#region PickupPoint
    public async Task<PickupPoint> CreatePickupPointAsync(PickupPoint pickupPoint) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO pickup_point (name, description, time_id, location_id, admin_id)
            VALUES (@name, @description, @time_id, @location_id, @admin_id)
            RETURNING *;";
        
        return await connection.QuerySingleAsync<PickupPoint>(sql, pickupPoint);
    }

    public async Task<PickupPoint> UpdatePickupPointAsync(PickupPoint pickupPoint) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE pickup_point 
            SET name = @name,
                description = @description,
                time_id = @time_id,
                location_id = @location_id,
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *;";

        return await connection.QuerySingleAsync<PickupPoint>(sql, pickupPoint);
    }

    public async Task<PickupPoint?> GetPickupPointByIdAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryFirstOrDefaultAsync<PickupPoint>("SELECT * FROM pickup_point where id = @id", new { id });
    }
    

    public async Task<IEnumerable<PickupPoint>> GetAllPickupPointsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
		return await connection.QueryAsync<PickupPoint>("SELECT * FROM pickup_point");
    }

    public async Task<IEnumerable<PhysicalDonation>> GetPhysicalDonationsByPickupPointIdAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            select d.*
            from physical_donation d
            join point_donation pd on d.id = pd.donation_id
            where pd.point_id = @id;";

        return await connection.QueryAsync<PhysicalDonation>(sql, new { id });
    }

    public async Task<PointTime> GetTimeByPickupPointIdAsync(int pickupPointId) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT pt.*
            FROM point_time pt
            JOIN pickup_point pp ON pt.id = pp.time_id
            where pp.time_id = @pickupPointId;";
        return await connection.QuerySingleAsync<PointTime>(sql, new { pickupPointId });
    }
#endregion

#region MeetingPoint
    public async Task<MeetingPoint> CreateMeetingPointAsync(MeetingPoint meetingPoint) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO meeting_point (name, description, time_id, location_id, admin_id)
            VALUES (@name, @description, @time_id, @location_id, @admin_id)
            RETURNING *;";
        
        return await connection.QuerySingleAsync<MeetingPoint>(sql, meetingPoint);
    }

    public async Task<MeetingPoint> UpdateMeetingPointAsync(MeetingPoint meetingPoint) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE meeting_point 
            SET name = @name,
                description = @description,
                time_id = @time_id,
                location_id = @location_id,
                admin_id = @admin_id
            WHERE id = @id
            RETURNING *;";

        return await connection.QuerySingleAsync<MeetingPoint>(sql, meetingPoint);
    }

    public async Task<MeetingPoint?> GetMeetingPointByIdAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryFirstOrDefaultAsync<MeetingPoint>("SELECT * FROM meeting_point where id = @id", new { id });
    }

    public async Task<IEnumerable<MeetingPoint>> GetAllMeetingPointsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<MeetingPoint>("SELECT * FROM meeting_point");
    }

    public async Task<PointTime> GetTimeByMeetingPointIdAsync(int meetingPointId) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT pt.*
            FROM point_time pt
            JOIN meeting_point mp ON pt.id = mp.time_id
            where mp.time_id = @meetingPointId;";
        return await connection.QuerySingleAsync<PointTime>(sql, new { meetingPointId });
    }
#endregion

}