namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class PlaceMapper 
{
    public static Place ToPlace(this PlaceCreateDto placeCreateDto) 
    {
        return new Place {
            name = placeCreateDto.name,
            admin_id = placeCreateDto.admin_id
        };
    }

    public static Place ToPlace(this PlaceUpdateDto placeUpdateDto) 
    {
        return new Place {
            id = placeUpdateDto.id,
            name = placeUpdateDto.name,
            admin_id = placeUpdateDto.admin_id
        };
    }

    public static PlaceDisplayDto ToPlaceDisplayDto(this Place place) 
    {
        return new PlaceDisplayDto {
            id = place.id,
            name = place.name,
            admin_id = place.admin_id
        };
    }
}