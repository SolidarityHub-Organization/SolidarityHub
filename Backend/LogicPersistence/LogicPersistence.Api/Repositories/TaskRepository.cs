namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class TaskRepository : ITaskRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Task> CreateTaskAsync(Task task)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO tasks (name, description, location, start_time, end_time, date, admin_id, location_id)
            VALUES (@name, @description, @location, @start_time, @end_time, @date, @admin_id, @location_id)
            RETURNING *";

        return await connection.QuerySingleAsync<Task>(sql, task);
    }

    public async Task<Task> UpdateTaskAsync(Task task)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE tasks 
            SET name = @name, 
                description = @description, 
                location = @location, 
                start_time = @start_time, 
                end_time = @end_time, 
                date = @date, 
                admin_id = @admin_id,,
                location_id = @location_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<Task>(sql, task);
    }

    public async Task<Task?> GetTaskByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM tasks WHERE id = @id";
        return await connection.QueryFirstOrDefaultAsync<Task>(sql, new { id });
    }

    public async Task<bool> DeleteTaskAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM tasks WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }
}