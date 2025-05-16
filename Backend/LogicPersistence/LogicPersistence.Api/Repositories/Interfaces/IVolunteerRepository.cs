namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public interface IVolunteerRepository
{
    Task<Volunteer> CreateVolunteerAsync(Volunteer volunteer);
    Task<Volunteer> UpdateVolunteerAsync(Volunteer volunteer);
    Task<bool> DeleteVolunteerAsync(int id);
    Task<IEnumerable<Volunteer>> GetAllVolunteersAsync();
    Task<Volunteer?> GetVolunteerByIdAsync(int id);
    Task<IEnumerable<VolunteerWithDetailsDisplayDto>> GetAllVolunteersWithDetailsAsync();
    Task<Volunteer?> GetVolunteerByEmailAsync(string email);
    Task<(IEnumerable<Volunteer> Volunteers, int TotalCount)> GetPaginatedVolunteersAsync(int pageNumber, int pageSize);
}
