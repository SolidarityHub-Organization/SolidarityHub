namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class AffectedZoneMapper 
{
    public static AffectedZone ToAffectedZone(this AffectedZoneCreateDto zoneCreateDto) 
    {
        return new AffectedZone {
            name = zoneCreateDto.name,
            description = zoneCreateDto.description,
            hazard_level = zoneCreateDto.hazard_level,
            admin_id = zoneCreateDto.admin_id
        };
    }

    public static AffectedZone ToAffectedZone(this AffectedZoneUpdateDto zoneUpdateDto) 
    {
        return new AffectedZone {
            id = zoneUpdateDto.id,
            name = zoneUpdateDto.name,
            description = zoneUpdateDto.description,
            hazard_level = zoneUpdateDto.hazard_level,
            admin_id = zoneUpdateDto.admin_id
        };
    }

    public static AffectedZoneDisplayDto ToAffectedZoneDisplayDto(this AffectedZone zone) 
    {
        return new AffectedZoneDisplayDto {
            id = zone.id,
            name = zone.name,
            description = zone.description,
            hazard_level = zone.hazard_level,
            admin_id = zone.admin_id
        };
    }
}