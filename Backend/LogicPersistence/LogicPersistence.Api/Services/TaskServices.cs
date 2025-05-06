using LogicPersistence.Api.Functionalities;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Services;

namespace LogicPersistence.Api.Services {
	public class TaskServices : ITaskServices {
		private readonly ITaskRepository _taskRepository;

		public TaskServices(ITaskRepository taskRepository) {
			_taskRepository = taskRepository;
		}


		public async Task<Models.Task> CreateTaskAsync(TaskCreateDto taskCreateDto) {
			if (taskCreateDto == null) {
				throw new ArgumentNullException(nameof(taskCreateDto));
			}

			var task = await _taskRepository.CreateTaskAsync(taskCreateDto.ToTask(), taskCreateDto.volunteer_ids, taskCreateDto.victim_ids);
			if (task == null) {
				throw new InvalidOperationException("Failed to create task.");
			}

			return task;
		}

		public async Task<Models.Task> GetTaskByIdAsync(int id) {
			var task = await _taskRepository.GetTaskByIdAsync(id);
			if (task == null) {
				throw new KeyNotFoundException($"Task with id {id} not found.");
			}
			return task;
		}

		public async Task<Models.Task> UpdateTaskAsync(int id, TaskUpdateDto taskUpdateDto) {
			if (id != taskUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}
			var existingTask = await _taskRepository.GetTaskByIdAsync(id);
			if (existingTask == null) {
				throw new KeyNotFoundException($"Task with id {id} not found.");
			}
			var updatedTask = taskUpdateDto.ToTask();
			await _taskRepository.UpdateTaskAsync(updatedTask, taskUpdateDto.volunteer_ids, taskUpdateDto.victim_ids);
			return updatedTask;
		}

		public async System.Threading.Tasks.Task DeleteTaskAsync(int id) {
			var existingTask = await _taskRepository.GetTaskByIdAsync(id);
			if (existingTask == null) {
				throw new KeyNotFoundException($"Task with id {id} not found.");
			}

			var deletionSuccesful = await _taskRepository.DeleteTaskAsync(id);
			if (!deletionSuccesful) {
				throw new InvalidOperationException($"Failed to delete task with id {id}.");
			}
		}

		public async Task<IEnumerable<Models.Task>> GetAllTasksAsync() {
			var victims = await _taskRepository.GetAllTasksAsync();
			if (victims == null) {
				throw new InvalidOperationException("Failed to retrieve tasks.");
			}
			return victims;
		}

		public async Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync() {
			var tasks = await _taskRepository.GetAllTasksWithDetailsAsync();
			if (tasks == null) {
				throw new InvalidOperationException("Failed to retrieve tasks with details.");
			}
			return tasks;
		}

		public async Task<Dictionary<State, IEnumerable<int>>> GetAllTaskIdsWithStatesAsync() {
			var taskStates = await _taskRepository.GetAllTaskIdsWithStatesAsync();
			if (taskStates == null) {
				throw new InvalidOperationException("Failed to retrieve tasks IDs with states.");
			}
			return taskStates.ToDictionary(
				x => x.state,
				x => x.task_ids.AsEnumerable()
			);
		}

		public async Task<Dictionary<State, int>> GetAllTaskCountByStateAsync(DateTime fromDate, DateTime toDate) {
			if (fromDate > toDate) {
				throw new ArgumentException("From date must be less than or equal to to date.");
			}
			var taskCounts = await _taskRepository.GetAllTaskCountByStateAsync(fromDate, toDate);
			if (taskCounts == null) {
				throw new InvalidOperationException("Failed to retrieve task counts by state.");
			}

			return taskCounts.ToDictionary(
				x => x.state,
				x => x.count
			);
		}

		public async Task<IEnumerable<int>> GetTaskIdsByStateAsync(string stateString) {
			if (!Enum.TryParse<State>(stateString, true, out State state)) {
				throw new ArgumentException($"Invalid state value: {stateString}");
			}

			var taskIds = await _taskRepository.GetTaskIdsByStateAsync(state);
			if (taskIds == null) {
				throw new InvalidOperationException($"Failed to retrieve task IDs for state {state}.");
			}
			return taskIds;
		}

		public async Task<IEnumerable<Models.Task>> GetTasksByStateAsync(string stateString, DateTime fromDate, DateTime toDate) {
			if (fromDate > toDate) {
				throw new ArgumentException("From date must be less than or equal to to date.");
			}
			if (!Enum.TryParse<State>(stateString, true, out State state)) {
				throw new ArgumentException($"Invalid state value: {stateString}");
			}

			var tasksIds = await GetTaskIdsByStateAsync(stateString);
			var tasks = await GetAllTasksAsync();
			tasks = tasks.Where(t => tasksIds.Contains(t.id) && t.created_at >= fromDate && t.created_at <= toDate).ToList();
			if (tasks.Count() == 0) {
				throw new InvalidOperationException($"No tasks found for state {state} in the specified date range.");
			}
			return tasks;
		}
		
		public async Task<int> GetTaskCountByStateAsync(string stateString, DateTime fromDate, DateTime toDate) {
			if (!Enum.TryParse<State>(stateString, true, out var state)) {
				throw new ArgumentException($"Invalid state value: {stateString}");
			}

			var tasksByState = await GetTasksByStateAsync(stateString, fromDate, toDate);
			return tasksByState.Count();
		}


		public async Task<IEnumerable<TaskForDashboardDto>> GetAllTasksForDashboardAsync(DateTime fromDate, DateTime toDate) {
			if (fromDate > toDate) {
				throw new ArgumentException("From date must be less than or equal to to date.");
			}
			var tasks = await _taskRepository.GetAllTasksAsync();
			if (tasks == null) {
				throw new InvalidOperationException("Failed to retrieve tasks for dashboard.");
			}
			tasks = tasks.Where(t => t.created_at >= fromDate && t.created_at <= toDate).ToList();
			if (tasks.Count() == 0) {
				throw new InvalidOperationException("No tasks found for the specified date range.");
			}

			var result = new List<TaskForDashboardDto>();
			foreach (var task in tasks) {
				var state = await _taskRepository.GetTaskStateByIdAsync(task.id);
				var urgency_level = await _taskRepository.GetMaxUrgencyLevelForTaskAsync(task.id);

				var taskForDashboard = new TaskForDashboardDto {
					id = task.id,
					name = task.name,
					urgency_level = urgency_level.GetDisplayName(),
					state = state.GetDisplayName(),
					affected_zone = GetAffectedZoneForTasks(task).Result
				};
				result.Add(taskForDashboard);
			}

			return result;
		}

		#region Internal Methods
		//devuelve la zona afectada a la que pertenece la tarea en caso de que exista, en caso contrario devuelve null
		//chapuza de método
		public async Task<AffectedZoneWithPointsDTO?> GetAffectedZoneForTasks(Models.Task task) {
			var locationRepository = new LocationRepository();
			var victimRepository = new VictimRepository();
			var volunteerRepository = new VolunteerRepository();
			var affectedZoneRepository = new AffectedZoneRepository();
			var taskRepository = _taskRepository;

			var mapServices = new MapServices(locationRepository, victimRepository, volunteerRepository, affectedZoneRepository, taskRepository);
			var locationServices = new LocationServices(locationRepository);

			var affectedZones = await mapServices.GetAllAffectedZonesWithPointsAsync();
			if (affectedZones == null) {
				throw new InvalidOperationException("Failed to retrieve affected zones.");
			}

			foreach (var affectedZone in affectedZones) {
				var taskLocation = await locationServices.GetLocationByIdAsync(task.location_id);
				if (taskLocation == null) {
					throw new KeyNotFoundException($"Location with id {task.location_id} not found.");
				}
				if (AffectedZoneServices.IsPointInAffectedZone(taskLocation.latitude, taskLocation.longitude, affectedZone)) {
					return affectedZone;
				}
			}

			return null;
		}

		public Task<IEnumerable<Models.Task>> GetTasksAssignedToVolunteerAsync(int volunteerId) {
			var tasks = _taskRepository.GetTasksAssignedToVolunteerAsync(volunteerId);
			if (tasks == null) {
				throw new InvalidOperationException($"Failed to retrieve tasks assigned to volunteer with id {volunteerId}.");
			}
			return tasks;
		}
		#endregion
	}
}
