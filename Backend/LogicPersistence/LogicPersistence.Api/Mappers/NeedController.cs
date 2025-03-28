namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class NeedMapper
{
    public static Need ToNeed(this NeedCreateDto needCreateDto)
    {
        return new Need {
            name = needCreateDto.name,
            description = needCreateDto.description,
            urgencyLevel = (UrgencyLevel)needCreateDto.urgencyLevel,
        }; 
    }
}