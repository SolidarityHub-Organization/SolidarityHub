namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

// Mappers transform data between DTOs and domain models.

public static class VictimMapper {
	/* The combination of static and this in ToVictim allows us to call the method as:
	var victim = victimCreateDto.ToVictim() or
	var victim = VictimMapper.ToVictim(victimCreateDto),
	the former allows us to skip instantiating a VictimMapper and to call the method directly on the DTO object. */
	public static Victim ToVictim(this VictimCreateDto victimCreateDto) {
		return new Victim {
			email = victimCreateDto.email,
			password = victimCreateDto.password,
			name = victimCreateDto.name,
			surname = victimCreateDto.surname,
			prefix = victimCreateDto.prefix,
			phone_number = victimCreateDto.phone_number,
			address = victimCreateDto.address,
			identification = victimCreateDto.identification
		};
	}

	public static Victim ToVictim(this VictimUpdateDto victimUpdateDto) {
		return new Victim {
			id = victimUpdateDto.id,
			email = victimUpdateDto.email,
			password = victimUpdateDto.password,
			name = victimUpdateDto.name,
			surname = victimUpdateDto.surname,
			prefix = victimUpdateDto.prefix,
			phone_number = victimUpdateDto.phone_number,
			address = victimUpdateDto.address,
			identification = victimUpdateDto.identification
		};
	}

	public static VictimDisplayDto ToVictimDisplayDto(this Victim victim) {
		return new VictimDisplayDto {
			id = victim.id,
			email = victim.email,
			name = victim.name,
			surname = victim.surname,
			prefix = victim.prefix,
			phone_number = victim.phone_number,
			address = victim.address,
			identification = victim.identification
			// Password is intentionally omitted.
		};
	}
}
