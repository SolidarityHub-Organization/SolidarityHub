namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

// Mappers transform data between DTOs and domain models.

public static class VictimMapper {
	public static Victim ToVictim(this VictimCreateDto victimCreateDto) {
		return new Victim {
			email = victimCreateDto.email,
			password = victimCreateDto.password,
			name = victimCreateDto.name,
			surname = victimCreateDto.surname,
			prefix = victimCreateDto.prefix,
			phone_number = victimCreateDto.phone_number,
			address = victimCreateDto.address,
			victim_id = victimCreateDto.victim_id
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
			victim_id = victimUpdateDto.victim_id
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
			victim_id = victim.victim_id
		};
	}
}
