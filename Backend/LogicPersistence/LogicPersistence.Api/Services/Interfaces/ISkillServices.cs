using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface ISkillServices
    {
        Task<Skill> CreateSkillAsync(SkillCreateDto skillCreateDto);
        Task<Skill> GetSkillByIdAsync(int id);  
        Task<Skill> UpdateSkillAsync(int id, SkillUpdateDto skillUpdateDto);
        System.Threading.Tasks.Task DeleteSkillAsync(int id);
        Task<IEnumerable<Skill>> GetAllSkillsAsync();
        Task<Dictionary<string, int>> GetSkillsWithVolunteerCountAsync(DateTime fromDate, DateTime toDate) ;
    }
    
}