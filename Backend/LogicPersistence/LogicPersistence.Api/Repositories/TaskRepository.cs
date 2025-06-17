namespace LogicPersistence.Api.Repositories;

using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Models.DTOs;
using Newtonsoft.Json;
using LogicPersistence.Api.Services;
using Task = LogicPersistence.Api.Models.Task;

public class TaskRepository : ITaskRepository {
    private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

    public async Task<Task> CreateTaskAsync(Task task, int[] volunteerIds, int[] victimIds) {
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

        try {
            var createdTask = await connection.QuerySingleAsync<Task>(taskSql, task, transaction);

            if (volunteerIds.Length > 0) {
                var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = createdTask.id, state = "Assigned" });
                await connection.ExecuteAsync(volunteerTaskSql, volunteerTasks, transaction);
            }

            if (victimIds.Length > 0) {
                var victimTasks = victimIds.Select(id => new { victim_id = id, task_id = createdTask.id, state = "Assigned" });
                await connection.ExecuteAsync(victimTaskSql, victimTasks, transaction);
            }

            await transaction.CommitAsync();
            return createdTask;
        } catch {
            await transaction.RollbackAsync();
            throw;
        }
    }

    public async Task<Task> UpdateTaskAsync(Task task, int[] volunteerIds, int[] victimIds) {
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

        try {
            var updatedTask = await connection.QuerySingleAsync<Task>(updateTaskSql, task, transaction);

            await connection.ExecuteAsync(deleteVolunteerTaskSql, new { task_id = updatedTask.id, volunteerIds }, transaction);

            if (volunteerIds.Length > 0) {
                var volunteerTasks = volunteerIds.Select(id => new { volunteer_id = id, task_id = updatedTask.id, state = "Assigned" });
                await connection.ExecuteAsync(insertVolunteerTaskSql, volunteerTasks, transaction);
            }

            await connection.ExecuteAsync(deleteVictimTaskSql, new { task_id = updatedTask.id, victimIds }, transaction);

            if (victimIds.Length > 0) {
                var victimTasks = victimIds.Select(id => new { victim_id = id, task_id = updatedTask.id, state = "Assigned" });
                await connection.ExecuteAsync(insertVictimTaskSql, victimTasks, transaction);
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
        ),
        task_skills AS (
            SELECT
                t.id as task_id,
                COALESCE(json_agg(json_build_object(
                    'id', s.id,
                    'name', s.name,
                    'level', s.level,
                    'admin_id', s.admin_id
                )) FILTER (WHERE s.id IS NOT NULL), '[]') AS skills
            FROM task t
            LEFT JOIN task_skill ts ON t.id = ts.task_id
            LEFT JOIN skill s ON ts.skill_id = s.id
            GROUP BY t.id
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
            tl.location_data AS locationJson,
            ts.skills AS skillsJson
        FROM task t
        LEFT JOIN task_volunteers tv ON t.id = tv.task_id
        LEFT JOIN task_victims tvi ON t.id = tvi.task_id
        LEFT JOIN task_location tl ON t.id = tl.task_id
        LEFT JOIN task_skills ts ON t.id = ts.task_id";

        var tasks = await connection.QueryAsync<TaskWithDetailsDto>(sql);

        foreach (var task in tasks) {
            task.assigned_volunteers = JsonConvert.DeserializeObject<IEnumerable<VolunteerDisplayDto>>(task.assigned_volunteersJson) ?? [];
            task.assigned_volunteersJson = "";

            task.assigned_victims = JsonConvert.DeserializeObject<IEnumerable<VictimDisplayDto>>(task.assigned_victimsJson) ?? [];
            task.assigned_victimsJson = "";

            if (task.locationJson != null) {
                task.location = JsonConvert.DeserializeObject<LocationDisplayDto>(task.locationJson);
                task.locationJson = "";
            }

            task.skills = JsonConvert.DeserializeObject<IEnumerable<SkillDisplayDto>>(task.skillsJson) ?? [];
            task.skillsJson = "";
        }

        return tasks;
    }

    public async Task<IEnumerable<(State state, int[] task_ids)>> GetAllTaskIdsWithStatesAsync() {
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

    public async Task<IEnumerable<(State state, int count)>> GetAllTaskCountByStateAsync(DateTime fromDate, DateTime toDate) {
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

        return await connection.QueryAsync<(State state, int count)>(sql, new {
            FromDate = fromDate,
            ToDate = toDate
        });
    }

    public async Task<int> GetTaskCountByStateAsync(State state) {
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

    public async Task<IEnumerable<int>> GetTaskIdsByStateAsync(State state) {
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

    public async Task<State> GetTaskStateByIdAsync(int taskId) {
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

    public async Task<UrgencyLevel> GetMaxUrgencyLevelForTaskAsync(int taskId) {
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

    public async Task<IEnumerable<Task>> GetTasksAssignedToVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
			SELECT *
			FROM task t
			JOIN volunteer_task vt ON t.id = vt.task_id
			JOIN location l ON l.id = t.location_id
			WHERE vt.volunteer_id = @volunteerId";

        return await connection.QueryAsync<Task>(sql, new { volunteerId });
    }

    public async Task<IEnumerable<TaskWithLocationInfoDto>> GetPendingTasksAssignedToVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
        SELECT t.*,
               l.latitude,
               l.longitude
        FROM task t
        JOIN volunteer_task vt ON t.id = vt.task_id
        JOIN location l ON t.location_id = l.id
        WHERE vt.volunteer_id = @volunteerId
          AND vt.state = 'Pending'
          AND NOT EXISTS (
            SELECT 1
            FROM volunteer_task vt2
            JOIN task_time tt1 ON tt1.task_id = vt2.task_id
            JOIN task_time tt2 ON tt2.task_id = t.id
            WHERE vt2.volunteer_id = @volunteerId
            AND vt2.state = 'Assigned'
              AND vt2.task_id != t.id 
              AND (
                tt1.date = tt2.date
                AND tt1.start_time < tt2.end_time
                AND tt1.end_time > tt2.start_time
              )
          )";

        var tasks = (await connection.QueryAsync<TaskWithLocationInfoDto>(sql, new { volunteerId })).ToList();

        // Fetch all task times for these tasks in a single query
        if (tasks.Count > 0) {
            var taskIds = tasks.Select(t => t.id).ToArray();
            const string timesSql = @"SELECT id, start_time::text as start_time, end_time::text as end_time, date, task_id FROM task_time WHERE task_id = ANY(@taskIds)";
            var timesRaw = (await connection.QueryAsync<dynamic>(timesSql, new { taskIds })).ToList();
            var times = timesRaw.Select(tr => new TaskTimeDisplayDto {
                id = tr.id,
                start_time = TimeOnly.Parse((string)tr.start_time),
                end_time = TimeOnly.Parse((string)tr.end_time),
                date = DateOnly.FromDateTime((DateTime)tr.date),
                task_id = tr.task_id
            }).ToList();
            foreach (var task in tasks) {
                task.times = times.Where(tt => tt.task_id == task.id).ToList();
            }
        }
        return tasks;
    }

    public async Task<IEnumerable<TaskWithLocationInfoDto>> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
        SELECT t.*,
               l.latitude,
               l.longitude
        FROM task t
        JOIN volunteer_task vt ON t.id = vt.task_id
        JOIN location l ON t.location_id = l.id
        WHERE vt.volunteer_id = @volunteerId AND vt.state = 'Assigned'";

        var tasks = (await connection.QueryAsync<TaskWithLocationInfoDto>(sql, new { volunteerId })).ToList();

        // Fetch all task times for these tasks in a single query
        if (tasks.Count > 0) {
            var taskIds = tasks.Select(t => t.id).ToArray();
            const string timesSql = @"SELECT id, start_time::text as start_time, end_time::text as end_time, date, task_id FROM task_time WHERE task_id = ANY(@taskIds)";
            var timesRaw = (await connection.QueryAsync<dynamic>(timesSql, new { taskIds })).ToList();
            var times = timesRaw.Select(tr => new TaskTimeDisplayDto {
                id = tr.id,
                start_time = TimeOnly.Parse((string)tr.start_time),
                end_time = TimeOnly.Parse((string)tr.end_time),
                date = DateOnly.FromDateTime((DateTime)tr.date),
                task_id = tr.task_id
            }).ToList();
            foreach (var task in tasks) {
                task.times = times.Where(tt => tt.task_id == task.id).ToList();
            }
        }
        return tasks;
    }

    public async Task<Task> UpdateTaskStateForVolunteerAsync(int volunteerId, int taskId, string state) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE volunteer_task
            SET state = @state::state
            WHERE volunteer_id = @volunteerId AND task_id = @taskId
            RETURNING *";

        var result = await connection.QuerySingleOrDefaultAsync<Task>(sql, new { volunteerId, taskId, state });
        if (result == null) {
            throw new InvalidOperationException("Task not found or update failed.");
        }
        return result;
    }

    public async Task<Location> GetTaskLocationAsync(int taskId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT l.*
            FROM task t
            JOIN location l ON t.location_id = l.id
            WHERE t.id = @taskId";

        return await connection.QuerySingleAsync<Location>(sql, new { taskId });
    }

    public async Task<IEnumerable<Skill>> GetTaskSkillsAsync(int taskId) {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT s.*
            FROM task_skill ts
            JOIN skill s ON ts.skill_id = s.id
            WHERE ts.task_id = @taskId";

        return await connection.QueryAsync<Skill>(sql, new { taskId });
    }
    
    public async System.Threading.Tasks.Task AssignVolunteersToTaskAsync(int taskId, List<int> volunteerIds, State st)
    {
        using var connection = new NpgsqlConnection(connectionString);
        
        foreach (int volunteerId in volunteerIds)
        {
            const string sql = @"
                INSERT INTO volunteer_task (volunteer_id, task_id, state)
                VALUES (@volunteerId, @taskId, @state::state)
                ON CONFLICT (volunteer_id, task_id) DO NOTHING";
            
            await connection.ExecuteAsync(sql, new { 
                volunteerId, 
                taskId, 
                state = st.ToString()
            });
        }
    }
}
