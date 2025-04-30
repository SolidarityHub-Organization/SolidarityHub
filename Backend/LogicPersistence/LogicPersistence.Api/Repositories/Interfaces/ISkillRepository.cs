using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces
{
    public interface ISkillRepository
    {
        Task<Skill> CreateSkillAsync(Skill skill);
        Task<bool> DeleteSkillAsync(int id);
        Task<Skill?> GetSkillByIdAsync(int id);
        Task<Skill> UpdateSkillAsync(Skill skill);
        Task<int> GetVolunteerCountById(int id, DateTime fromDate, DateTime toDate);
        Task<IEnumerable<Skill>> GetAllSkillsAsync();
    }
}