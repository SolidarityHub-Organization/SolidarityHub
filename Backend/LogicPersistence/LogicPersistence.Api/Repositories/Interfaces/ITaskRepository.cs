using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Repositories;

public interface ITaskRepository {
    Task<Models.Task> CreateTaskAsync(Models.Task task, int[] volunteerIds);
    Task<Models.Task> UpdateTaskAsync(Models.Task task);
    Task<bool> DeleteTaskAsync(int id);
    Task<IEnumerable<Models.Task>> GetAllTasksAsync();
    Task<Models.Task?> GetTaskByIdAsync(int id);
    Task<IEnumerable<TaskWithDetailsDto>> GetAllTasksWithDetailsAsync();
}
