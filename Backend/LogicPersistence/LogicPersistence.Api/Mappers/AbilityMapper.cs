namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

// Mappers transform data between DTOs and domain models.

public static class AbilityMapper {
    public static Ability ToAbility(this AbilityCreateDto AbilityCreateDto) {
        return new Ability {
            name = AbilityCreateDto.name,
            level = AbilityCreateDto.level
        };
    }

    public static Ability ToAbility(this AbilityUpdateDto AbilityUpdateDto) {
        return new Ability {
            id = AbilityUpdateDto.id,
            name = AbilityUpdateDto.name,
            level = AbilityUpdateDto.level
        };
    }

    public static AbilityDisplayDto ToAbilityDisplayDto(this Ability Ability) {
        return new AbilityDisplayDto {
            id = Ability.id,
            name = Ability.name,
            level = Ability.level
        };
    }
}