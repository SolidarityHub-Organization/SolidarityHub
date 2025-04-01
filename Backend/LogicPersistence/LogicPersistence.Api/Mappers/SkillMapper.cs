namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class SkillMapper {
    public static Skill ToSkill(this SkillCreateDto skillCreateDto) {
        return new Skill {
            name = skillCreateDto.name,
            level = skillCreateDto.level,
            admin_id = skillCreateDto.admin_id
        };
    }

    public static Skill ToSkill(this SkillUpdateDto skillUpdateDto) {
        return new Skill {
            id = skillUpdateDto.id,
            name = skillUpdateDto.name,
            level = skillUpdateDto.level,
            admin_id = skillUpdateDto.admin_id
        };
    }

    public static SkillDisplayDto ToSkillDisplayDto(this Skill skill) {
        return new SkillDisplayDto {
            id = skill.id,
            name = skill.name,
            level = skill.level,
            admin_id = skill.admin_id
        };
    }
}
