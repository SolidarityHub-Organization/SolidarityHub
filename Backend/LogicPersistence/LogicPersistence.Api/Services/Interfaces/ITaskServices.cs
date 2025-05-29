using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services {
	public interface ITaskServices {
		Task<Models.Task> CreateTaskAsync(TaskCreateDto taskCreateDto);
		Task<Models.Task> GetTaskByIdAsync(int id);
		Task<Models.Task> UpdateTaskAsync(int id, TaskUpdateDto taskUpdateDto);
		System.Threading.Tasks.Task DeleteTaskAsync(int id);
		Task<IEnumerable<Models.Task>> GetAllTasksAsync();
		Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync();
		Task<Dictionary<State, IEnumerable<int>>> GetAllTaskIdsWithStatesAsync();
		Task<Dictionary<State, int>> GetAllTaskCountByStateAsync(DateTime fromDate, DateTime toDate);
		Task<State> GetTaskStateByIdAsync(int id);
		Task<int> GetTaskCountByStateAsync(string stateString, DateTime fromDate, DateTime toDate);
		Task<IEnumerable<int>> GetTaskIdsByStateAsync(string stateString);
		Task<IEnumerable<TaskForDashboardDto>> GetAllTasksForDashboardAsync(DateTime fromDate, DateTime toDate);
		Task<IEnumerable<Models.Task>> GetTasksByStateAsync(string stateString, DateTime fromDate, DateTime toDate);
		Task<IEnumerable<Models.Task>> GetTasksAssignedToVolunteerAsync(int volunteerId);
		Task<IEnumerable<TaskWithLocationInfoDto>> GetPendingTasksAssignedToVolunteerAsync(int volunteerId);
		Task<IEnumerable<TaskWithLocationInfoDto>> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId);
		Task<Models.Task> UpdateTaskStateForVolunteerAsync(int volunteerId, int taskId, UpdateTaskStateDto updateTaskStateDto);
		Task<string> GetMaxUrgencyLevelForTaskAsync(int taskId);
		Task<(IEnumerable<Models.Task> Tasks, int TotalCount)> GetPaginatedTasksAsync(int pageNumber, int pageSize);
		Task<(IEnumerable<Models.Task> Tasks, int TotalCount)> GetPaginatedTasksForDashboardAsync(DateTime fromDate, DateTime toDate, int page, int size);
	}
}
