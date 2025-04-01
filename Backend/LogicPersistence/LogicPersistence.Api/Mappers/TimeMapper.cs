namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class TimeMapper 
{
    public static Time ToTime(this TimeCreateDto timeCreateDto) 
    {
        return new Time {
            time_slot = timeCreateDto.time_slot,
            day = timeCreateDto.day
        };
    }

    public static Time ToTime(this TimeUpdateDto timeUpdateDto) 
    {
        return new Time {
            time_slot = timeUpdateDto.time_slot,
            day = timeUpdateDto.day
        };
    }

    public static TimeDisplayDto ToTimeDisplayDto(this Time time) 
    {
        return new TimeDisplayDto {
            time_slot = time.time_slot,
            day = time.day
        };
    }
}