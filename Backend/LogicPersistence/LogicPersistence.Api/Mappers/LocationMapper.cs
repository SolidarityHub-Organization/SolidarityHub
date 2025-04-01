namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class LocationMapper 
{
    public static Location ToLocation(this LocationCreateDto locationCreateDto) 
    {
        return new Location {
            latitude = locationCreateDto.latitude,
            longitude = locationCreateDto.longitude,
            victim_id = locationCreateDto.victim_id ?? -1,
            volunteer_id = locationCreateDto.volunteer_id ?? -1
        };
    }

    public static Location ToLocation(this LocationUpdateDto locationUpdateDto) 
    {
        return new Location {
            latitude = locationUpdateDto.latitude,
            longitude = locationUpdateDto.longitude,
            victim_id = locationUpdateDto.victim_id ?? -1,
            volunteer_id = locationUpdateDto.volunteer_id ?? -1
        };
    }

    public static LocationDisplayDto ToLocationDisplayDto(this Location location) 
    {
        return new LocationDisplayDto {
            latitude = location.latitude,
            longitude = location.longitude,
            victim_id = location.victim_id,
            volunteer_id = location.volunteer_id
        };
    }
}