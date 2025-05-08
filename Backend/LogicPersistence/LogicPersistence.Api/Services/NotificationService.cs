using Dapper;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Services.Interfaces;
using Npgsql;

namespace LogicPersistence.Api.Services;

public class NotificationService : INotificationService {
    private readonly string _connectionString;

    public NotificationService() {
        _connectionString = DatabaseConfiguration.GetConnectionString();
    }

    public async Task<IEnumerable<Notification>> GetNotificationsForVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(_connectionString);
        const string sql = @"
            SELECT * 
            FROM notifications
            WHERE volunteer_id = @volunteerId";

        return await connection.QueryAsync<Notification>(sql, new { volunteerId });
    }

    public async Task<IEnumerable<Notification>> GetNotificationsForVictimAsync(int victimId) {
        using var connection = new NpgsqlConnection(_connectionString);
        const string sql = @"
            SELECT * 
            FROM notifications
            WHERE victim_id = @victimId";

        return await connection.QueryAsync<Notification>(sql, new { victimId });
    }
}
