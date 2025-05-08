using LogicPersistence.Api.Services;
using LogicPersistence.Api.Models.DTOs;
//using LogicPersistence.Api.Strategies;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers {
    
[ApiController]
[Route("api/v1")]
public class StrategyController : ControllerBase
{
    private readonly IServiceProvider _serviceProvider;

    public StrategyController(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    [HttpGet("strategy")]
    public async Task<IActionResult> GetStrategy([FromQuery] string strategyType)
    {
        try
        {
            // Selecciona la estrategia en función del parámetro `strategyType`
            var strategy = strategyType?.ToLower() switch
            {
                "heatmap" => _serviceProvider.GetService<IMapStrategy<AffectedZoneWithPointsDTO>>(),

                // Agrega más estrategias aquí según sea necesario
                _ => throw new ArgumentException("Invalid strategy type")
            };

            if (strategy == null)
            {
                return BadRequest("Estrategia no encontrada");
            }

            // Crea el contexto con la estrategia seleccionada
            var strategyContext = new StrategyContext<AffectedZoneWithPointsDTO>(strategy);

            // Llama al método MostrarStrategy para obtener los datos
            var result = await strategyContext.MostrarStrategy();
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message); // Devuelve un error 400 si el parámetro es inválido
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error al ejecutar la estrategia: {ex.Message}");
        }
    }
}     
}
