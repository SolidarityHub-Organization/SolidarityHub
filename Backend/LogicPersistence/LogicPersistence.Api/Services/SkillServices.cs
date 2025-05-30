using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Services.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class SkillService : ISkillServices {
        private readonly ISkillRepository _skillRepository;
        private readonly IPaginationService _paginationService;

        public SkillService(ISkillRepository skillRepository, IPaginationService paginationService) {
            _skillRepository = skillRepository;
            _paginationService = paginationService;
        }

        public async Task<Skill> CreateSkillAsync(SkillCreateDto skillCreateDto) {
            if (skillCreateDto == null) {
                throw new ArgumentNullException(nameof(skillCreateDto));
            }

            var skill = await _skillRepository.CreateSkillAsync(skillCreateDto.ToSkill());
            if (skill == null) {
                throw new InvalidOperationException("Failed to create skill.");
            }
            return skill;
        }

        public async Task<Skill> GetSkillByIdAsync(int id) {
            var skill = await _skillRepository.GetSkillByIdAsync(id);
            if (skill == null) {
                throw new KeyNotFoundException($"Skill with id {id} not found.");
            }
            return skill;
        }

        public async Task<Skill> UpdateSkillAsync(int id, SkillUpdateDto skillUpdateDto) {
            if (id != skillUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }

            var existingSkill = await _skillRepository.GetSkillByIdAsync(id);
            if (existingSkill == null) {
                throw new KeyNotFoundException($"Skill with id {id} not found.");
            }

            var updatedSkill = skillUpdateDto.ToSkill();
            return await _skillRepository.UpdateSkillAsync(updatedSkill);
        }

        public async System.Threading.Tasks.Task DeleteSkillAsync(int id) {
            var existingSkill = await _skillRepository.GetSkillByIdAsync(id);
            if (existingSkill == null) {
                throw new KeyNotFoundException($"Skill with id {id} not found.");
            }

            var deletionSuccessful = await _skillRepository.DeleteSkillAsync(id);
            if (!deletionSuccessful) {
                throw new InvalidOperationException($"Failed to delete skill with id {id}.");
            }
        }

        public async Task<IEnumerable<Skill>> GetAllSkillsAsync() {
            var skills = await _skillRepository.GetAllSkillsAsync();
            if (skills == null) {
                throw new InvalidOperationException("Failed to retrieve skills.");
            }
            return skills;
        }

        public async Task<Dictionary<string, int>> GetSkillsWithVolunteerCountAsync(DateTime fromDate, DateTime toDate) {
            var skills = await _skillRepository.GetAllSkillsAsync();
            if (skills == null) {
                throw new InvalidOperationException("Failed to retrieve skills.");
            }

            Dictionary<string, int> result = new Dictionary<string, int>();
            foreach (Skill skill in skills) {
                var count = await _skillRepository.GetVolunteerCountById(skill.id, fromDate, toDate);
                result.Add(skill.name, count);
            }
            return result;
        }
        
        public async Task<(IEnumerable<Skill> Skills, int TotalCount)> GetPaginatedSkillsAsync(int pageNumber, int pageSize) {
			return await _paginationService.GetPaginatedAsync<Skill>(pageNumber, pageSize, "skill", "created_at DESC, id DESC");
		}
    }
}