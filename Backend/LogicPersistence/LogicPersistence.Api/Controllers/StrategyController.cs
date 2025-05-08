using LogicPersistence.Api.Services;
using LogicPersistence.Api.Models.DTOs;
//using LogicPersistence.Api.Strategies;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers {
    
[ApiController]
[Route("api/v1")]
public abstract class StrategyController<T> : ControllerBase
{
    private readonly StrategyContext<T> _context;

    public StrategyController(StrategyContext<T> context)
    {
        _context = context;
    }

    [HttpGet("mostrar")]
    public async Task<IActionResult> Mostrar()
    {
        var result = await _context.MostrarStrategy();
        return Ok(result);
    }

}

[Route("api/v1/heatmap")]
public class HeatMapController : StrategyController<AffectedZoneWithPointsDTO>
{
    public HeatMapController(StrategyContext<AffectedZoneWithPointsDTO> context) : base(context) { }
}
}
