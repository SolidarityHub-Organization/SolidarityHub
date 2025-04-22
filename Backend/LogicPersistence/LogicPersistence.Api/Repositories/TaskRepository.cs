namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Repositories.Interfaces;
using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Models.DTOs;
using Newtonsoft.Json;

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

			if (volunteerIds.Length > 0) {
				var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = createdTask.id, state = "Assigned" });
				await connection.ExecuteAsync(volunteerTaskSql, volunteerTasks, transaction);
			}

			await transaction.CommitAsync();
			return createdTask;
		} catch {
			await transaction.RollbackAsync();
			throw;
		}
	}

	public async Task<Task> UpdateTaskAsync(Task task, int[] volunteerIds) {
		using var connection = new NpgsqlConnection(connectionString);
		await connection.OpenAsync();
		using var transaction = await connection.BeginTransactionAsync();

		const string updateTaskSql = @"
            UPDATE task
            SET name = @name,
                description = @description,
                admin_id = @admin_id,
                location_id = @location_id
            WHERE id = @id
            RETURNING *";

		const string insertVolunteerTaskSql = @"
			INSERT INTO volunteer_task (volunteer_id, task_id, state)
			SELECT @volunteer_id, @task_id, @state::state
			WHERE NOT EXISTS (
				SELECT 1 FROM volunteer_task
				WHERE volunteer_id = @volunteer_id AND task_id = @task_id
			)";

		const string deleteVolunteerTaskSql = @"
			DELETE FROM volunteer_task
			WHERE task_id = @task_id AND volunteer_id <> ALL(@volunteerIds)";

		try {
			var updatedTask = await connection.QuerySingleAsync<Task>(updateTaskSql, task, transaction);

			await connection.ExecuteAsync(deleteVolunteerTaskSql, new { task_id = updatedTask.id, volunteerIds }, transaction);

			if (volunteerIds.Length > 0) {
				var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = updatedTask.id, state = "Assigned" });
				await connection.ExecuteAsync(insertVolunteerTaskSql, volunteerTasks, transaction);
			}

			await transaction.CommitAsync();
			return updatedTask;
		} catch {
			await transaction.RollbackAsync();
			throw;
		}
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

	public async Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync() {
		using var connection = new NpgsqlConnection(connectionString);

		const string sql = @"
        SELECT
            t.id,
            t.name,
            t.description,
            t.admin_id,
            t.location_id,
            COALESCE(json_agg(json_build_object(
                'id', v.id,
                'email', v.email,
                'name', v.name,
                'surname', v.surname,
                'prefix', v.prefix,
                'phone_number', v.phone_number,
                'address', v.address,
                'identification', v.identification,
                'location_id', v.location_id
            )) FILTER (WHERE v.id IS NOT NULL), '[]') AS assigned_volunteersJson
        FROM task t
        LEFT JOIN volunteer_task vt ON t.id = vt.task_id
        LEFT JOIN volunteer v ON vt.volunteer_id = v.id
        GROUP BY t.id";


		var tasks = await connection.QueryAsync<TaskWithDetailsDto>(sql);

		foreach (var task in tasks) {
			task.assigned_volunteers = JsonConvert.DeserializeObject<IEnumerable<VolunteerDisplayDto>>(task.assigned_volunteersJson) ?? [];
			task.assigned_volunteersJson = "";
		}

		return tasks;
	}

	public async Task<IEnumerable<(State state, int[] task_ids)>> GetTasksWithStatesAsync()
	{
		using var connection = new NpgsqlConnection(connectionString);
		const string sql = @"
			SELECT vt.state, array_agg(t.id) AS task_ids
			FROM task t
			LEFT JOIN volunteer_task vt ON t.id = vt.task_id
			WHERE vt.state IS NOT NULL
			GROUP BY vt.state";

		return await connection.QueryAsync<(State state, int[] task_ids)>(sql);
	}
	
}
