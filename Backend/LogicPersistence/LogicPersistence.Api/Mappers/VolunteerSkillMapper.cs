namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class VolunteerSkillMapper {
    public static VolunteerSkill ToVolunteerSkill(this VolunteerSkillCreateDto VolunteerSkillCreateDto) {
        return new VolunteerSkill {
            volunteer_id = VolunteerSkillCreateDto.volunteer_id,
            skill_id = VolunteerSkillCreateDto.skill_id
        };
    }

    public static VolunteerSkill ToVolunteerSkill(this VolunteerSkillUpdateDto VolunteerSkillUpdateDto) {
		return new VolunteerSkill {
			volunteer_id = VolunteerSkillUpdateDto.volunteer_id,
            skill_id = VolunteerSkillUpdateDto.skill_id
        };
    }

    public static VolunteerSkillDisplayDto ToVolunteerSkillDisplayDto(this VolunteerSkill VolunteerSkill) {
        return new VolunteerSkillDisplayDto {
            volunteer_id = VolunteerSkill.volunteer_id,
            skill_id = VolunteerSkill.skill_id
        };
    }
}
