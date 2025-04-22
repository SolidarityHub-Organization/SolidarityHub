using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;

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

			var task = await _taskRepository.CreateTaskAsync(taskCreateDto.ToTask(), taskCreateDto.volunteer_ids);
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
			await _taskRepository.UpdateTaskAsync(updatedTask, taskUpdateDto.volunteer_ids);
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

		public async Task<Dictionary<State, IEnumerable<int>>> GetAllTaskIdsWithStatesAsync()
		{
			var taskStates = await _taskRepository.GetAllTaskIdsWithStatesAsync();
			if (taskStates == null) {
				throw new InvalidOperationException("Failed to retrieve tasks IDs with states.");
			}
			return taskStates.ToDictionary(
				x => x.state,
				x => x.task_ids.AsEnumerable()
			);
		}

		public async Task<Dictionary<State, int>> GetAllTaskCountByStateAsync()
		{
			var taskCounts = await _taskRepository.GetAllTaskCountByStateAsync();
			if (taskCounts == null)
			{
				throw new InvalidOperationException("Failed to retrieve task counts by state.");
			}
			
			return taskCounts.ToDictionary(
				x => x.state,
				x => x.count
			);
		}

		public async Task<int> GetTaskCountByStateAsync(State state)
		{
			var count = await _taskRepository.GetTaskCountByStateAsync(state);
			return count;
		}

		public async Task<int> GetTaskCountByStateAsync(string stateString)
		{
			if (!Enum.TryParse<State>(stateString, true, out var state))
			{
				throw new ArgumentException($"Invalid state value: {stateString}");
			}
			
			var count = await _taskRepository.GetTaskCountByStateAsync(state);
			return count;
		}

		public async Task<IEnumerable<int>> GetTaskIdsByStateAsync(string stateString)
		{
			if (!Enum.TryParse<State>(stateString, true, out State state))
			{
				throw new ArgumentException($"Invalid state value: {stateString}");
			}

			var taskIds = await _taskRepository.GetTaskIdsByStateAsync(state);
			if (taskIds == null)
			{
				throw new InvalidOperationException($"Failed to retrieve task IDs for state {state}.");
			}
			return taskIds;
		}
	}
}
