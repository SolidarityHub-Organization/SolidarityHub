namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class NeedMapper {
    public static Need ToNeed(this NeedCreateDto needCreateDto) {
        return new Need {
            name = needCreateDto.name,
            description = needCreateDto.description,
            urgencyLevel = needCreateDto.urgencyLevel,
            victim_id = needCreateDto.victim_id,
            admin_id = needCreateDto.admin_id
        };
    }

    public static Need ToNeed(this NeedUpdateDto needUpdateDto) {
        return new Need {
            id = needUpdateDto.id,
            name = needUpdateDto.name,
            description = needUpdateDto.description,
            urgencyLevel = needUpdateDto.urgencyLevel,
            victim_id = needUpdateDto.victim_id,
            admin_id = needUpdateDto.admin_id
        };
    }

    public static NeedDisplayDto ToNeedDisplayDto(this Need need) {
        return new NeedDisplayDto {
            id = need.id,
            name = need.name,
            description = need.description,
            urgencyLevel = need.urgencyLevel,
            victim_id = need.victim_id,
            admin_id = need.admin_id
        };
    }
}
