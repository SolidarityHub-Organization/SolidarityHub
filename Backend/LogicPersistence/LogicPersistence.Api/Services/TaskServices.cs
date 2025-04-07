using LogicPersistence.Api.Mappers;
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

            var task = await _taskRepository.CreateTaskAsync(taskCreateDto.ToTask());
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
            await _taskRepository.UpdateTaskAsync(updatedTask);
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
    }
}
