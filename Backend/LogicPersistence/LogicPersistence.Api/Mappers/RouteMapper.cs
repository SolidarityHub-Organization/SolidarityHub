namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class RouteMapper 
{
    public static Route ToRoute(this RouteCreateDto routeCreateDto) 
    {
        return new Route {
            name = routeCreateDto.name,
            description = routeCreateDto.description,
            hazard_level = routeCreateDto.hazard_level,
            transport_type = routeCreateDto.transport_type,
            admin_id = routeCreateDto.admin_id ?? -1,
            start_location_id = routeCreateDto.start_location_id,
            end_location_id = routeCreateDto.end_location_id
        };
    }

    public static Route ToRoute(this RouteUpdateDto routeUpdateDto) 
    {
        return new Route {
            id = routeUpdateDto.id,
            name = routeUpdateDto.name,
            description = routeUpdateDto.description,
            hazard_level = routeUpdateDto.hazard_level,
            transport_type = routeUpdateDto.transport_type,
            admin_id = routeUpdateDto.admin_id ?? -1,
            start_location_id = routeUpdateDto.start_location_id,
            end_location_id = routeUpdateDto.end_location_id
        };
    }

    public static RouteDisplayDto ToRouteDisplayDto(this Route route) 
    {
        return new RouteDisplayDto {
            id = route.id,
            name = route.name,
            description = route.description,
            hazard_level = route.hazard_level,
            transport_type = route.transport_type,
            admin_id = route.admin_id,
            start_location_id = route.start_location_id,
            end_location_id = route.end_location_id
        };
    }
}