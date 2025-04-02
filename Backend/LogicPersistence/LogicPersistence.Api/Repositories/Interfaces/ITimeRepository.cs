using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces;

public interface ITimeRepository
{
    // Task Time operations
    Task<TaskTime> CreateTaskTimeAsync(TaskTime taskTime);
    Task<TaskTime> UpdateTaskTimeAsync(TaskTime taskTime);
    Task<bool> DeleteTaskTimeAsync(int id);
    Task<IEnumerable<TaskTime>> GetTaskTimesByTaskIdAsync(int taskId);




    // Volunteer Time operations
    Task<VolunteerTime> CreateVolunteerTimeAsync(VolunteerTime volunteerTime);
    Task<VolunteerTime> UpdateVolunteerTimeAsync(VolunteerTime volunteerTime);
    Task<bool> DeleteVolunteerTimeAsync(int id);
    Task<IEnumerable<VolunteerTime>> GetVolunteerTimesByVolunteerIdAsync(int volunteerId);
}