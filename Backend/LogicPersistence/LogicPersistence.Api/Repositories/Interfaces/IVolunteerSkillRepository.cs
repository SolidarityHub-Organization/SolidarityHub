using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories
{
    public interface IVolunteerSkillRepository
    {
        Task<VolunteerSkill> CreateVolunteerSkillAsync(VolunteerSkill volunteerSkill);
        Task<VolunteerSkill?> GetVolunteerSkillByIdAsync(int volunteer_id, int skill_id);
        Task<VolunteerSkill> UpdateVolunteerSkillAsync(VolunteerSkill volunteerSkill);
        System.Threading.Tasks.Task DeleteVolunteerSkillAsync(int volunteer_id, int skill_id);
        Task<IEnumerable<VolunteerSkill>> GetAllVolunteerSkillsAsync();
    }
}
