using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Repositories;

public interface ITaskRepository {
	Task<Models.Task> CreateTaskAsync(Models.Task task, int[] volunteerIds, int[] victimIds);
	Task<Models.Task> UpdateTaskAsync(Models.Task task, int[] volunteerIds, int[] victimIds);
	Task<bool> DeleteTaskAsync(int id);
	Task<IEnumerable<Models.Task>> GetAllTasksAsync();
	Task<Models.Task?> GetTaskByIdAsync(int id);
	Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync();
	Task<IEnumerable<(State state, int[] task_ids)>> GetAllTaskIdsWithStatesAsync();
	Task<IEnumerable<(State state, int count)>> GetAllTaskCountByStateAsync(DateTime fromDate, DateTime toDate);
	Task<int> GetTaskCountByStateAsync(State state);
	Task<IEnumerable<int>> GetTaskIdsByStateAsync(State state);
	Task<State> GetTaskStateByIdAsync(int taskId);
	Task<UrgencyLevel> GetMaxUrgencyLevelForTaskAsync(int taskId);
	Task<IEnumerable<Models.Task>> GetTasksAssignedToVolunteerAsync(int volunteerId);
	Task<IEnumerable<TaskWithLocationInfoDto>> GetPendingTasksAssignedToVolunteerAsync(int volunteerId);
	Task<IEnumerable<TaskWithLocationInfoDto>> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId);
	Task<Models.Task> UpdateTaskStateForVolunteerAsync(int volunteerId, int taskId, string state);
	Task<Location> GetTaskLocationAsync(int taskId);
}
