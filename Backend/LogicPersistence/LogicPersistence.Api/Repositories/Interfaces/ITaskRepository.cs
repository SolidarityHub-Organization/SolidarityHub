using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces;

public interface ITaskRepository
{
    Task<Models.Task> CreateTaskAsync(Models.Task task);
    Task<Models.Task> UpdateTaskAsync(Models.Task task);
    Task<bool> DeleteTaskAsync(int id);
    Task<Models.Task?> GetTaskByIdAsync(int id);
}