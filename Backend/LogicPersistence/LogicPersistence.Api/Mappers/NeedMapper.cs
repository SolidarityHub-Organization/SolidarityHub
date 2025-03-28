namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class NeedMapper {
	public static Need ToNeed(this NeedCreateDto needCreateDto) {
		return new Need {
			name = needCreateDto.name,
			description = needCreateDto.description,
			urgencyLevel = (UrgencyLevel)needCreateDto.urgencyLevel,
		};
	}

	public static Need ToNeed(this NeedUpdateDto needUpdateDto) {
		return new Need {
			id = needUpdateDto.id,
			name = needUpdateDto.name,
			description = needUpdateDto.description,
			urgencyLevel = (UrgencyLevel)needUpdateDto.urgencyLevel,
		};
	}

	public static NeedDisplayDto ToNeedDisplayDto(this Need need) {
		return new NeedDisplayDto {
			id = need.id,
			name = need.name,
			description = need.description,
			urgencyLevel = need.urgencyLevel.ToString(),
		};
	}
}
