namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class NeedTypeMapper {
    public static NeedType ToNeedType(this NeedTypeCreateDto needTypeCreateDto) {
        return new NeedType {
            name = needTypeCreateDto.name,
            admin_id = needTypeCreateDto.admin_id
        };
    }

    public static NeedType ToNeedType(this NeedTypeUpdateDto needTypeUpdateDto) {
        return new NeedType {
            id = needTypeUpdateDto.id,
            name = needTypeUpdateDto.name,
            admin_id = needTypeUpdateDto.admin_id
        };
    }

    public static NeedTypeDisplayDto ToNeedTypeDisplayDto(this NeedType needType) {
        return new NeedTypeDisplayDto {
            id = needType.id,
            name = needType.name,
            admin_id = needType.admin_id
        };
    }
}
