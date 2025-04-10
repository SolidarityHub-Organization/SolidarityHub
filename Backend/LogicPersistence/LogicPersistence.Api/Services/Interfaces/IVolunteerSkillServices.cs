using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IVolunteerSkillServices
    {
        Task<VolunteerSkill> CreateVolunteerSkillAsync(VolunteerSkillCreateDto VolunteerSkillCreateDto);
        Task<VolunteerSkillDisplayDto> GetVolunteerSkillByIdAsync(int volunteer_id, int skill_id);
        Task<VolunteerSkill> UpdateVolunteerSkillAsync(int volunteer_id, int skill_id, VolunteerSkillUpdateDto volunteerSkillUpdateDto);
        System.Threading.Tasks.Task DeleteVolunteerSkillAsync(int volunteer_id, int skill_id);
        Task<IEnumerable<VolunteerSkill>> GetAllVolunteerSkillsAsync();
    }
    
}