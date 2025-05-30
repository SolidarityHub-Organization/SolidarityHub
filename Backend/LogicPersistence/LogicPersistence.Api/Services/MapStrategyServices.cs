using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;

public class MapStrategyServices {
    public async Task<IEnumerable<AffectedZoneWithPointsDTO>> Mostrar<AffectedZoneCreateDto>(MapStrategyCreateDto<AffectedZoneCreateDto> mapStrategyCreateDto, IMapServices iMapServices) {
        var map = new Map ();
        
        if (mapStrategyCreateDto.Strategy == null) {
            throw new InvalidOperationException("No se implementa ninguna estrategia.");
        }

        IMapStrategy<AffectedZoneWithPointsDTO> strategy = mapStrategyCreateDto.Strategy.ToLower() switch
        {
            "heatmap" => (IMapStrategy<AffectedZoneWithPointsDTO>)new HeatMapStrategy(iMapServices),
            // Puedes añadir más estrategias aquí
            _ => throw new ArgumentException($"Estrategia '{mapStrategyCreateDto.Strategy}' no soportada")
        };
        map.setStrategy(strategy);
        var items = await map.MostrarStrategy();
        return items;
    }
}