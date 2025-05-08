using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;

public class HeatMapStrategy : IMapStrategy<AffectedZoneWithPointsDTO>
{
    private readonly IMapServices _mapService;

     public HeatMapStrategy(IMapServices mapService)
    {
        _mapService = mapService;
    }

    public Task<IEnumerable<AffectedZoneWithPointsDTO>> Mostrar()
    {
        return _mapService.GetAllAffectedZonesWithPointsAsync();
    }
}