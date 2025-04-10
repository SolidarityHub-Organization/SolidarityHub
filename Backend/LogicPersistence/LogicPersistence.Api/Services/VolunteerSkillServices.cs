using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Mappers;

namespace LogicPersistence.Api.Services
{
    public class VolunteerSkillServices : IVolunteerSkillServices
    {
        private readonly IVolunteerSkillRepository _volunteerSkillRepository;

        public VolunteerSkillServices(IVolunteerSkillRepository volunteerSkillRepository)
        {
            _volunteerSkillRepository = volunteerSkillRepository;
        }

        public async Task<VolunteerSkill> CreateVolunteerSkillAsync(VolunteerSkillCreateDto volunteerSkillCreateDto)
        {
            if (volunteerSkillCreateDto == null)
            {
                throw new ArgumentNullException(nameof(volunteerSkillCreateDto));
            }

            var volunteerSkill = await _volunteerSkillRepository.CreateVolunteerSkillAsync(volunteerSkillCreateDto.ToVolunteerSkill());
            if (volunteerSkill == null)
            {
                throw new InvalidOperationException("Failed to create volunteer skill.");
            }

            return volunteerSkill;
        }

        public async Task<VolunteerSkillDisplayDto> GetVolunteerSkillByIdAsync(int volunteer_id, int skill_id)
        {
            var volunteerSkill = await _volunteerSkillRepository.GetVolunteerSkillByIdAsync(volunteer_id, skill_id);
            if (volunteerSkill == null)
            {
                throw new KeyNotFoundException($"VolunteerSkill with volunteer_id {volunteer_id} and skill_id {skill_id} not found.");
            }
            return volunteerSkill.ToVolunteerSkillDisplayDto();
        }

        public async Task<VolunteerSkill> UpdateVolunteerSkillAsync(int volunteer_id, int skill_id, VolunteerSkillUpdateDto volunteerSkillUpdateDto)
        {
            if (volunteer_id != volunteerSkillUpdateDto.volunteer_id || skill_id != volunteerSkillUpdateDto.skill_id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingVolunteerSkill = await _volunteerSkillRepository.GetVolunteerSkillByIdAsync(volunteer_id, skill_id);
            if (existingVolunteerSkill == null)
            {
                throw new KeyNotFoundException($"VolunteerSkill with volunteer_id {volunteer_id} and skill_id {skill_id} not found.");
            }
            var updatedVolunteerSkill = volunteerSkillUpdateDto.ToVolunteerSkill();
            return await _volunteerSkillRepository.UpdateVolunteerSkillAsync(updatedVolunteerSkill);
        }

        public async System.Threading.Tasks.Task DeleteVolunteerSkillAsync(int volunteer_id, int skill_id)
        {
            var existingVolunteerSkill = await _volunteerSkillRepository.GetVolunteerSkillByIdAsync(volunteer_id, skill_id);
            if (existingVolunteerSkill == null)
            {
                throw new KeyNotFoundException($"VolunteerSkill with volunteer_id {volunteer_id} and skill_id {skill_id} not found.");
            }
            await _volunteerSkillRepository.DeleteVolunteerSkillAsync(volunteer_id, skill_id);
        }

        public async Task<IEnumerable<VolunteerSkill>> GetAllVolunteerSkillsAsync()
        {
            var volunteerSkills = await _volunteerSkillRepository.GetAllVolunteerSkillsAsync();
            if (volunteerSkills == null)
            {
                throw new InvalidOperationException("Failed to retrieve volunteer skills.");
            }
            return volunteerSkills;
        }
    }
}