using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services 
{
    public interface IVolunteerServices 
    {
        Task<Volunteer> CreateVolunteerAsync(VolunteerCreateDto volunteerCreateDto);
        Task<Volunteer> GetVolunteerByIdAsync(int id);
        Task<Volunteer> UpdateVolunteerAsync(int id, VolunteerUpdateDto volunteerUpdateDto);
        Task DeleteVolunteerAsync(int id);
        Task<IEnumerable<Volunteer>> GetAllVolunteersAsync();
        Task<Volunteer?> GetVolunteerByEmailAsync(string email);
    }
}