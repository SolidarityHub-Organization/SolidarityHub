using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services {
	public interface ITaskServices {
		Task<Models.Task> CreateTaskAsync(TaskCreateDto taskCreateDto);
		Task<Models.Task> GetTaskByIdAsync(int id);
		Task<Models.Task> UpdateTaskAsync(int id, TaskUpdateDto taskUpdateDto);
		Task DeleteTaskAsync(int id);
		Task<IEnumerable<Models.Task>> GetAllTasksAsync();
	}
}
