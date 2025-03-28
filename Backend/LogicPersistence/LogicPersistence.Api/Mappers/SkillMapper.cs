namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class SkillMapper {
	public static Skill ToSkill(this SkillCreateDto skillCreateDto) {
		return new Skill {
			name = skillCreateDto.name,
			level = (SkillLevel)skillCreateDto.level
		};
	}

	public static Skill ToSkill(this SkillUpdateDto skillUpdateDto) {
		return new Skill {
			id = skillUpdateDto.id,
			name = skillUpdateDto.name,
			level = (SkillLevel)skillUpdateDto.level
		};
	}

	public static SkillDisplayDto ToSkillDisplayDto(this Skill skill) {
		return new SkillDisplayDto {
			id = skill.id,
			name = skill.name,
			level = skill.level.ToString()
		};
	}

}
