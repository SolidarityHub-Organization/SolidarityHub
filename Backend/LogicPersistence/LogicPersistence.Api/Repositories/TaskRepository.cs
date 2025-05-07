namespace LogicPersistence.Api.Repositories;

using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Models.DTOs;
using Newtonsoft.Json;

public class TaskRepository : ITaskRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Task> CreateTaskAsync(Task task, int[] volunteerIds, int[] victimIds)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        using var transaction = await connection.BeginTransactionAsync();

        const string taskSql = @"
            INSERT INTO task (name, description, admin_id, location_id, start_date, end_date)
            VALUES (@name, @description, @admin_id, @location_id, @start_date, @end_date)
            RETURNING *";

        const string volunteerTaskSql = @"
            INSERT INTO volunteer_task (volunteer_id, task_id, state)
            VALUES (@volunteer_id, @task_id, @state::state)";

        const string victimTaskSql = @"
            INSERT INTO victim_task (victim_id, task_id, state)
            VALUES (@victim_id, @task_id, @state::state)";

        try
        {
            var createdTask = await connection.QuerySingleAsync<Task>(taskSql, task, transaction);

            if (volunteerIds.Length > 0)
            {
                var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = createdTask.id, state = "Assigned" });
                await connection.ExecuteAsync(volunteerTaskSql, volunteerTasks, transaction);
            }

            if (victimIds.Length > 0)
            {
                var victimTasks = victimIds.Select(id => new { victim_id = id, task_id = createdTask.id, state = "Assigned" });
                await connection.ExecuteAsync(victimTaskSql, victimTasks, transaction);
            }

            await transaction.CommitAsync();
            return createdTask;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    public async Task<Task> UpdateTaskAsync(Task task, int[] volunteerIds, int[] victimIds)
    {
        using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        using var transaction = await connection.BeginTransactionAsync();

        const string updateTaskSql = @"
            UPDATE task
            SET name = @name,
                description = @description,
                admin_id = @admin_id,
                location_id = @location_id,
                start_date = @start_date,
                end_date = @end_date
            WHERE id = @id
            RETURNING *";

        const string insertVolunteerTaskSql = @"
			INSERT INTO volunteer_task (volunteer_id, task_id, state)
			SELECT @volunteer_id, @task_id, @state::state
			WHERE NOT EXISTS (
				SELECT 1 FROM volunteer_task
				WHERE volunteer_id = @volunteer_id AND task_id = @task_id
			)";

        const string insertVictimTaskSql = @"
			INSERT INTO victim_task (victim_id, task_id, state)
			SELECT @victim_id, @task_id, @state::state
			WHERE NOT EXISTS (
				SELECT 1 FROM victim_task
				WHERE victim_id = @victim_id AND task_id = @task_id
			)";

        const string deleteVolunteerTaskSql = @"
			DELETE FROM volunteer_task
			WHERE task_id = @task_id AND volunteer_id <> ALL(@volunteerIds)";

        const string deleteVictimTaskSql = @"
			DELETE FROM victim_task
			WHERE task_id = @task_id AND victim_id <> ALL(@victimIds)";

        try
        {
            var updatedTask = await connection.QuerySingleAsync<Task>(updateTaskSql, task, transaction);

            await connection.ExecuteAsync(deleteVolunteerTaskSql, new { task_id = updatedTask.id, volunteerIds }, transaction);

            if (volunteerIds.Length > 0)
            {
                var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = updatedTask.id, state = "Assigned" });
                await connection.ExecuteAsync(insertVolunteerTaskSql, volunteerTasks, transaction);
            }

            await connection.ExecuteAsync(deleteVictimTaskSql, new { task_id = updatedTask.id, victimIds }, transaction);

            if (victimIds.Length > 0)
            {
                var victimTasks = victimIds.Select(id => new { victim_id = id, task_id = updatedTask.id, state = "Assigned" });
                await connection.ExecuteAsync(insertVictimTaskSql, victimTasks, transaction);
            }

            await transaction.CommitAsync();
            return updatedTask;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    public async Task<Task?> GetTaskByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM task WHERE id = @id";
        return await connection.QueryFirstOrDefaultAsync<Task>(sql, new { id });
    }

    public async Task<bool> DeleteTaskAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM task WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<Task>> GetAllTasksAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        return await connection.QueryAsync<Task>("SELECT * FROM task");
    }

    public async Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);

        const string sql = @"
        WITH task_volunteers AS (
            SELECT
                t.id as task_id,
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
                )) FILTER (WHERE v.id IS NOT NULL), '[]') AS volunteers
            FROM task t
            LEFT JOIN volunteer_task vt ON t.id = vt.task_id
            LEFT JOIN volunteer v ON vt.volunteer_id = v.id
            GROUP BY t.id
        ),
        task_victims AS (
            SELECT
                t.id as task_id,
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
                )) FILTER (WHERE v.id IS NOT NULL), '[]') AS victims
            FROM task t
            LEFT JOIN victim_task vt ON t.id = vt.task_id
            LEFT JOIN victim v ON vt.victim_id = v.id
            GROUP BY t.id
        ),
        task_location AS (
            SELECT
                t.id as task_id,
                json_build_object(
                    'id', l.id,
                    'latitude', l.latitude,
                    'longitude', l.longitude,
                    'victim_id', l.victim_id,
                    'volunteer_id', l.volunteer_id
                ) AS location_data
            FROM task t
            LEFT JOIN location l ON t.location_id = l.id
        )
        SELECT
            t.id,
            t.name,
            t.description,
            t.admin_id,
            t.location_id,
            t.start_date,
            t.end_date,
            tv.volunteers AS assigned_volunteersJson,
            tvi.victims AS assigned_victimsJson,
            tl.location_data AS locationJson
        FROM task t
        LEFT JOIN task_volunteers tv ON t.id = tv.task_id
        LEFT JOIN task_victims tvi ON t.id = tvi.task_id
        LEFT JOIN task_location tl ON t.id = tl.task_id";

        var tasks = await connection.QueryAsync<TaskWithDetailsDto>(sql);

        foreach (var task in tasks)
        {
            task.assigned_volunteers = JsonConvert.DeserializeObject<IEnumerable<VolunteerDisplayDto>>(task.assigned_volunteersJson) ?? [];
            task.assigned_volunteersJson = "";

            task.assigned_victims = JsonConvert.DeserializeObject<IEnumerable<VictimDisplayDto>>(task.assigned_victimsJson) ?? [];
            task.assigned_victimsJson = "";

            if (task.locationJson != null)
            {
                task.location = JsonConvert.DeserializeObject<LocationDisplayDto>(task.locationJson);
                task.locationJson = "";
            }
        }

        return tasks;
    }

    public async Task<IEnumerable<(State state, int[] task_ids)>> GetAllTaskIdsWithStatesAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT state, array_agg(task_id) AS task_ids
			FROM (
				SELECT vt.state, t.id as task_id
				FROM task t
				LEFT JOIN volunteer_task vt ON t.id = vt.task_id
				WHERE vt.state IS NOT NULL
				UNION
				SELECT vit.state, t.id as task_id
				FROM task t
				LEFT JOIN victim_task vit ON t.id = vit.task_id
				WHERE vit.state IS NOT NULL
			) combined
			GROUP BY state";

        return await connection.QueryAsync<(State state, int[] task_ids)>(sql);
    }

    public async Task<IEnumerable<(State state, int count)>> GetAllTaskCountByStateAsync(DateTime fromDate, DateTime toDate)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT state, COUNT(task_id) as count
			FROM (
				SELECT DISTINCT t.id as task_id, vt.state
				FROM task t
				LEFT JOIN volunteer_task vt ON t.id = vt.task_id
				WHERE vt.state IS NOT NULL
				AND t.created_at BETWEEN @fromDate AND @toDate
				UNION
				SELECT DISTINCT t.id as task_id, vit.state
				FROM task t
				LEFT JOIN victim_task vit ON t.id = vit.task_id
				WHERE vit.state IS NOT NULL
				AND t.created_at BETWEEN @fromDate AND @toDate
			) combined
			GROUP BY state";

        return await connection.QueryAsync<(State state, int count)>(sql, new
        {
            FromDate = fromDate,
            ToDate = toDate
        });
    }

    public async Task<int> GetTaskCountByStateAsync(State state)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT COUNT(DISTINCT task_id)
			FROM (
				SELECT t.id as task_id
				FROM task t
				LEFT JOIN volunteer_task vt ON t.id = vt.task_id
				WHERE vt.state = @state::state
				UNION
				SELECT t.id as task_id
				FROM task t
				LEFT JOIN victim_task vit ON t.id = vit.task_id
				WHERE vit.state = @state::state
			) combined";

        return await connection.QuerySingleOrDefaultAsync<int>(sql, new { state = state.ToString() });
    }

    public async Task<IEnumerable<int>> GetTaskIdsByStateAsync(State state)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT DISTINCT task_id
			FROM (
				SELECT t.id as task_id
				FROM task t
				LEFT JOIN volunteer_task vt ON t.id = vt.task_id
				WHERE vt.state = @state::state
				UNION
				SELECT t.id as task_id
				FROM task t
				LEFT JOIN victim_task vit ON t.id = vit.task_id
				WHERE vit.state = @state::state
			) combined";

        return await connection.QueryAsync<int>(sql, new { state = state.ToString() });
    }

    public async Task<State> GetTaskStateByIdAsync(int taskId)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT DISTINCT state::text
			FROM (
				SELECT vt.state
				FROM task t
				LEFT JOIN volunteer_task vt ON t.id = vt.task_id
				WHERE t.id = @taskId AND vt.state IS NOT NULL
				UNION
				SELECT vit.state
				FROM task t
				LEFT JOIN victim_task vit ON t.id = vit.task_id
				WHERE t.id = @taskId AND vit.state IS NOT NULL
			) combined
			LIMIT 1";

        var result = await connection.QuerySingleOrDefaultAsync<string>(sql, new { taskId });
        return result != null ? Enum.Parse<State>(result) : State.Unknown;
    }

    public async Task<UrgencyLevel> GetMaxUrgencyLevelForTaskAsync(int taskId)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT MAX(n.urgency_level::text)
			FROM task t
			JOIN need_task nt ON t.id = nt.task_id
			JOIN need n ON nt.need_id = n.id
			WHERE t.id = @taskId";

        var result = await connection.QuerySingleOrDefaultAsync<string>(sql, new { taskId });
        return result != null ? Enum.Parse<UrgencyLevel>(result) : UrgencyLevel.Unknown;
    }

    public async Task<IEnumerable<Task>> GetTasksAssignedToVolunteerAsync(int volunteerId)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT t.*
			FROM task t
			JOIN volunteer_task vt ON t.id = vt.task_id
			WHERE vt.volunteer_id = @volunteerId";

        return await connection.QueryAsync<Task>(sql, new { volunteerId });
    }

	public async Task<IEnumerable<Task>> GetPendingTasksAssignedToVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT t.*
			FROM task t
			JOIN volunteer_task vt ON t.id = vt.task_id
            WHERE vt.volunteer_id = @volunteerId AND vt.state = 'Pending'";

        return await connection.QueryAsync<Task>(sql, new { volunteerId });
	}

	public async Task<IEnumerable<Task>> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT t.*
			FROM task t
			JOIN volunteer_task vt ON t.id = vt.task_id
            WHERE vt.volunteer_id = @volunteerId AND vt.state = 'Assigned'";

        return await connection.QueryAsync<Task>(sql, new { volunteerId });
	}
}
