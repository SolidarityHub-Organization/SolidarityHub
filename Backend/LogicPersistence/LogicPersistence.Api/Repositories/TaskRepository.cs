namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class TaskRepository : ITaskRepository {
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Task> CreateTaskAsync(Task task, int[] volunteerIds) {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        using var transaction = await connection.BeginTransactionAsync();

        const string taskSql = @"
            INSERT INTO task (name, description, admin_id, location_id)
            VALUES (@name, @description, @admin_id, @location_id)
            RETURNING *";

        const string volunteerTaskSql = @"
            INSERT INTO volunteer_task (volunteer_id, task_id, state)
            VALUES (@volunteer_id, @task_id, @state::state)";

        try {
            var createdTask = await connection.QuerySingleAsync<Task>(taskSql, task, transaction);

            Console.WriteLine($"Created task: {createdTask.id}");

            if (volunteerIds.Length > 0) {
                var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = createdTask.id, state = "Assigned" });
                await connection.ExecuteAsync(volunteerTaskSql, volunteerTasks, transaction);
            }

            Console.WriteLine($"Assigned volunteers to task: {createdTask.id}");

            await transaction.CommitAsync();
            return createdTask;
        } catch {
            await transaction.RollbackAsync();
            throw;
        }
    }

    public async Task<Task> UpdateTaskAsync(Task task) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE task 
            SET name = @name, 
                description = @description, 
                admin_id = @admin_id,
                location_id = @location_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<Task>(sql, task);
    }

    public async Task<Task?> GetTaskByIdAsync(int id) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM task WHERE id = @id";
        return await connection.QueryFirstOrDefaultAsync<Task>(sql, new { id });
    }

    public async Task<bool> DeleteTaskAsync(int id) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM task WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<Task>> GetAllTasksAsync() {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Task>("SELECT * FROM task");
    }


}