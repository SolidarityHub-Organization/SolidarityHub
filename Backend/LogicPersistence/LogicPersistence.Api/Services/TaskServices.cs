using LogicPersistence.Api.Functionalities;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;
using LogicPersistence.Api.Services.Interfaces;
using LogicPersistence.Api.Services.ObserverPattern;
using Task = LogicPersistence.Api.Models.Task;

namespace LogicPersistence.Api.Services {
	public class TaskServices : ITaskServices {
		private readonly ITaskRepository _taskRepository;
		private readonly ILocationRepository _locationRepository;
		private readonly IVictimRepository _victimRepository;
		private readonly IVolunteerRepository _volunteerRepository;
		private readonly IAffectedZoneRepository _affectedZoneRepository;
		private readonly IPointRepository _pointRepository;
		private readonly IPaginationService _paginationService;
		private readonly List<ITaskAssignmentObserver> _observers = new();

		public void RegisterObserver(ITaskAssignmentObserver observer) {
			_observers.Add(observer);
		}
		public void UnregisterObserver(ITaskAssignmentObserver observer) {
			_observers.Remove(observer);
		}
		private void NotifyTaskAssigned(int volunteerId, int taskId, string taskName) {
			foreach (var observer in _observers) {
				observer.OnTaskAssigned(volunteerId, taskId, taskName);
			}
		}

		public TaskServices(
			ITaskRepository taskRepository,
			ILocationRepository locationRepository,
			IVictimRepository victimRepository,
			IVolunteerRepository volunteerRepository,
			IAffectedZoneRepository affectedZoneRepository,
			IPointRepository pointRepository,
			IPaginationService paginationService) {
			_taskRepository = taskRepository;
			_locationRepository = locationRepository;
			_victimRepository = victimRepository;
			_volunteerRepository = volunteerRepository;
			_affectedZoneRepository = affectedZoneRepository;
			_pointRepository = pointRepository;
			_paginationService = paginationService;
		}

		protected virtual void ValidateState(string stateString) {
			if (!Enum.TryParse<State>(stateString, true, out _)) {
				throw new ArgumentException($"Valor de estado no válido: {stateString}");
			}
		}

		protected virtual async Task<T> ExecuteWithValidation<T>(Func<Task<T>> operation, string errorMessage) where T : class {
			var result = await operation();
			if (result == null) {
				throw new InvalidOperationException(errorMessage);
			}
			return result;
		}

		public async Task<Models.Task> CreateTaskAsync(TaskCreateDto taskCreateDto) {
			if (taskCreateDto == null) {
				throw new ArgumentNullException(nameof(taskCreateDto));
			}

			var task = await ExecuteWithValidation(
				() => _taskRepository.CreateTaskAsync(taskCreateDto.ToTask(), taskCreateDto.volunteer_ids, taskCreateDto.victim_ids),
				"Failed to create task."
			);

			foreach (var volunteerId in taskCreateDto.volunteer_ids) {
				NotifyTaskAssigned(volunteerId, task.id, task.name);
			}
			return task;
		}

		public async Task<Models.Task> GetTaskByIdAsync(int id) {
			return await ExecuteWithValidation(
				() => _taskRepository.GetTaskByIdAsync(id),
				$"Task with id {id} not found."
			);
		}

		public async Task<Models.Task> UpdateTaskAsync(int id, TaskUpdateDto taskUpdateDto) {
			if (id != taskUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}

			await ExecuteWithValidation(
				() => _taskRepository.GetTaskByIdAsync(id),
				$"Task with id {id} not found."
			);

			var updatedTask = taskUpdateDto.ToTask();
			return await ExecuteWithValidation(
				() => _taskRepository.UpdateTaskAsync(updatedTask, taskUpdateDto.volunteer_ids, taskUpdateDto.victim_ids),
				$"Failed to update task with id {id}."
			);
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
			GeneralServices.ValidateDates(fromDate, toDate);
			var taskCounts = await _taskRepository.GetAllTaskCountByStateAsync(fromDate, toDate);
			if (taskCounts == null) {
				throw new InvalidOperationException("Failed to retrieve task counts by state.");
			}

			return taskCounts.ToDictionary(
				x => x.state,
				x => x.count
			);
		}

		public async Task<State> GetTaskStateByIdAsync(int id) {
			var state = await _taskRepository.GetTaskStateByIdAsync(id);
			return state;
		}

		public async Task<IEnumerable<int>> GetTaskIdsByStateAsync(string stateString) {
			ValidateState(stateString);
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
			GeneralServices.ValidateDates(fromDate, toDate);
			ValidateState(stateString);

			var tasksIds = await GetTaskIdsByStateAsync(stateString);
			var tasks = await GetAllTasksAsync();
			tasks = tasks.Where(t => tasksIds.Contains(t.id) && t.created_at >= fromDate && t.created_at <= toDate).ToList();

			if (!tasks.Any()) {
				throw new InvalidOperationException($"No tasks found for state {stateString} in the specified date range.");
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
			GeneralServices.ValidateDates(fromDate, toDate);
			var tasks = await _taskRepository.GetAllTasksAsync() ?? throw new InvalidOperationException("Failed to retrieve tasks for dashboard.");

			tasks = tasks.Where(t => t.created_at >= fromDate && t.created_at <= toDate).ToList();
			if (tasks.Count() == 0) {
				throw new InvalidOperationException("No tasks found for the specified date range.");
			}

			var result = new List<TaskForDashboardDto>();
			foreach (var task in tasks) { result.Add(await CreateTaskForDashboardDto(task)); }

			return result;
		}

		public Task<IEnumerable<Models.Task>> GetTasksAssignedToVolunteerAsync(int volunteerId) {
			var tasks = _taskRepository.GetTasksAssignedToVolunteerAsync(volunteerId);
			if (tasks == null) {
				throw new InvalidOperationException($"Failed to retrieve tasks assigned to volunteer with id {volunteerId}.");
			}
			return tasks;
		}

		public Task<IEnumerable<TaskWithLocationInfoDto>> GetPendingTasksAssignedToVolunteerAsync(int volunteerId) {
			var tasks = _taskRepository.GetPendingTasksAssignedToVolunteerAsync(volunteerId);
			if (tasks == null) {
				throw new InvalidOperationException($"Failed to retrieve tasks assigned to volunteer with id {volunteerId}.");
			}
			return tasks;
		}

		public Task<IEnumerable<TaskWithLocationInfoDto>> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId) {
			var tasks = _taskRepository.GetAssignedTasksAssignedToVolunteerAsync(volunteerId);
			if (tasks == null) {
				throw new InvalidOperationException($"Failed to retrieve tasks assigned to volunteer with id {volunteerId}.");
			}
			return tasks;
		}

		public Task<Models.Task> UpdateTaskStateForVolunteerAsync(int volunteerId, int taskId, UpdateTaskStateDto updateTaskStateDto) {
			if (updateTaskStateDto == null) {
				throw new ArgumentNullException(nameof(updateTaskStateDto));
			}
			var task = _taskRepository.UpdateTaskStateForVolunteerAsync(volunteerId, taskId, updateTaskStateDto.state);
			if (task == null) {
				throw new InvalidOperationException($"Failed to update task state for volunteer with id {volunteerId} and task with id {taskId}.");
			}
			return task;
		}

		public async Task<string> GetMaxUrgencyLevelForTaskAsync(int taskId) {
			var urgencyLevel = await _taskRepository.GetMaxUrgencyLevelForTaskAsync(taskId);
			return urgencyLevel.GetDisplayName();
		}

		public async Task<(IEnumerable<Models.Task> Tasks, int TotalCount)> GetPaginatedTasksAsync(int pageNumber, int pageSize) {
			return await _paginationService.GetPaginatedAsync<Models.Task>(
				pageNumber,
				pageSize,
				"task",
				"created_at DESC, id DESC");
		}

		public async Task<(IEnumerable<TaskForDashboardDto> Tasks, int TotalCount)> GetPaginatedTasksForDashboardAsync(DateTime fromDate, DateTime toDate, int page, int size) {
			GeneralServices.ValidateDates(fromDate, toDate);
			var tasks = await _taskRepository.GetAllTasksAsync() ?? throw new InvalidOperationException("Failed to retrieve tasks for dashboard.");

			var filteredTasks = tasks.Where(t => t.created_at >= fromDate && t.created_at <= toDate).ToList();
			var totalCount = filteredTasks.Count;

			if (totalCount == 0) { return (Enumerable.Empty<TaskForDashboardDto>(), 0); }

			var paginatedTasks = filteredTasks
				.OrderByDescending(t => t.created_at)
				.Skip((page - 1) * size)
				.Take(size)
				.ToList();

			var result = new List<TaskForDashboardDto>();
			foreach (var task in paginatedTasks) { result.Add(await CreateTaskForDashboardDto(task)); }

			return (result, totalCount);
		}



		#region Internal Methods
		//devuelve la zona afectada a la que pertenece la tarea en caso de que exista, en caso contrario devuelve null
		//chapuza de método	//el chapuzador que bien chapuzee, buen chapuzeador será
		public async Task<AffectedZoneWithPointsDTO?> GetAffectedZoneForTasks(Models.Task task) {
			var mapServices = new MapServices(_locationRepository, _victimRepository, _volunteerRepository, _affectedZoneRepository, _taskRepository, _pointRepository);

			var affectedZones = await mapServices.GetAllAffectedZonesWithPointsAsync();
			if (affectedZones == null) {
				throw new InvalidOperationException("Failed to retrieve affected zones.");
			}

			foreach (var affectedZone in affectedZones) {
				var taskLocation = await _locationRepository.GetLocationByIdAsync(task.location_id);
				if (taskLocation == null) {
					throw new KeyNotFoundException($"Location with id {task.location_id} not found.");
				}
				if (AffectedZoneServices.IsPointInAffectedZone(taskLocation.latitude, taskLocation.longitude, affectedZone)) {
					return affectedZone;
				}
			}

			return null;
		}

		internal async Task<TaskForDashboardDto> CreateTaskForDashboardDto(Models.Task task) {
			var state = await _taskRepository.GetTaskStateByIdAsync(task.id);
			var urgencyLevel = await GetMaxUrgencyLevelForTaskAsync(task.id);
			var location = await _taskRepository.GetTaskLocationAsync(task.id);

			return new TaskForDashboardDto {
				id = task.id,
				name = task.name,
				urgency_level = urgencyLevel,
				state = state.GetDisplayName(),
				affected_zone = await GetAffectedZoneForTasks(task),
				start_date = task.start_date,
				end_date = task.end_date,
				latitude = location.latitude,
				longitude = location.longitude,
			};
		}
		#endregion
	}
}
