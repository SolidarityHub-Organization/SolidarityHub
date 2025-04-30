using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services 
{
    public interface IVolunteerServices 
    
    {
        // use System.Threading.Tasks.Task instead of Task for async methods to avoid ambiguity with the Task class and System.Threading.Tasks if some return is just "Task"
        Task<Volunteer> CreateVolunteerAsync(VolunteerCreateDto volunteerCreateDto);
        Task<Volunteer> GetVolunteerByIdAsync(int id);
        Task<VolunteerDisplayDto> GetVolunteerDisplayByIdAsync(int id);
        Task<Volunteer> UpdateVolunteerAsync(int id, VolunteerUpdateDto volunteerUpdateDto);
        System.Threading.Tasks.Task DeleteVolunteerAsync(int id);
        Task<IEnumerable<Volunteer>> GetAllVolunteersAsync();
        Task<Volunteer?> GetVolunteerByEmailAsync(string email);
        Task<int> GetVolunteersCountAsync(DateTime fromDate, DateTime toDate);
    }
}