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
		Task<int> GetTaskCountByStateAsync(string stateString, DateTime fromDate, DateTime toDate);
		Task<IEnumerable<int>> GetTaskIdsByStateAsync(string stateString);
		Task<IEnumerable<TaskForDashboardDto>> GetAllTasksForDashboardAsync(DateTime fromDate, DateTime toDate);
		Task<IEnumerable<Models.Task>> GetTasksByStateAsync(string stateString, DateTime fromDate, DateTime toDate);
	}
}
