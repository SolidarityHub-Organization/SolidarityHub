namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IVolunteerRepository 
{
    Task<Volunteer> CreateVolunteerAsync(Volunteer volunteer);
    Task<Volunteer> UpdateVolunteerAsync(Volunteer volunteer);
    Task DeleteVolunteerAsync(int id);
    Task<IEnumerable<Volunteer>> GetAllVolunteersAsync();
    Task<Volunteer?> GetVolunteerByIdAsync(int id);
    Task<Volunteer?> GetVolunteerByEmailAsync(string email);
}