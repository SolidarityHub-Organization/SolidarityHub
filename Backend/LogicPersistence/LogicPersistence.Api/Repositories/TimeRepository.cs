using Dapper;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Repositories.Interfaces;
using Npgsql;

namespace LogicPersistence.Api.Repositories;

public class DuplicateTimeException : Exception
{
    public DuplicateTimeException(TimeOnly start, TimeOnly end, string type) 
        : base($"{type} time slot already exists: {start:HH:mm} - {end:HH:mm}") { }
}

public class TimeRepository : ITimeRepository
{
    private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

    // Task Time Methods
    public async Task<TaskTime> UpdateTaskTimeAsync(TaskTime taskTime)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE task_time 
            SET start_time = @start_time, 
                end_time = @end_time,
                date = @date
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<TaskTime>(sql, taskTime);
    }

    public async Task<TaskTime> CreateTaskTimeAsync(TaskTime taskTime)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO task_time (start_time, end_time, date, task_id)
            VALUES (@start_time, @end_time, @date, @task_id)
            RETURNING *";

        return await connection.QuerySingleAsync<TaskTime>(sql, taskTime);
    }

    public async Task<bool> DeleteTaskTimeAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM task_time WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<TaskTime>> GetTaskTimesByTaskIdAsync(int taskId)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT * FROM task_time 
            WHERE task_id = @taskId";

        return await connection.QueryAsync<TaskTime>(sql, new { taskId });
        // this return is equivalent to:
        /*
        var result = new List<TaskTime>();
        var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            result.Add(new TaskTime {
                id = reader.GetInt32("id"),
                start_time = reader.GetTimeOnly("start_time"),
                end_time = reader.GetTimeOnly("end_time"),
                date = reader.GetDateOnly("date"),
                task_id = reader.GetInt32("task_id")
            });
        }
        return result;
        */
    }








    // Volunteer Time Methods
    public async Task<VolunteerTime> UpdateVolunteerTimeAsync(VolunteerTime volunteerTime)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE volunteer_time
            SET start_time = @start_time, 
                end_time = @end_time,
                day = @day
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<VolunteerTime>(sql, volunteerTime);
    }

    public async Task<VolunteerTime> CreateVolunteerTimeAsync(VolunteerTime volunteerTime)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO volunteer_time (start_time, end_time, day, volunteer_id)
            VALUES (@start_time, @end_time, @day, @volunteer_id)
            RETURNING *";

        return await connection.QuerySingleAsync<VolunteerTime>(sql, volunteerTime);
    }

    public async Task<bool> DeleteVolunteerTimeAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
		const string sql = "DELETE FROM volunteer_time WHERE id = @id";

		int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<VolunteerTime>> GetVolunteerTimesByVolunteerIdAsync(int volunteerId)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT * FROM volunteer_time 
            WHERE volunteer_id = @volunteerId";

        return await connection.QueryAsync<VolunteerTime>(sql, new { volunteerId });
    }
}