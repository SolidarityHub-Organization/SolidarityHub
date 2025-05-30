using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers {

    [Route("api/v1")]
    [ApiController]
    public class StrategyController : ControllerBase {
        protected readonly IMapServices _iMapServices;
        protected readonly MapStrategyServices _mapStrategyServices;
        public StrategyController(IMapServices iMapServices, MapStrategyServices mapStrategyServices) {
            _iMapServices = iMapServices;
            _mapStrategyServices = mapStrategyServices;
        }

        [HttpPost("map/mostrar")]
        public async Task<IActionResult> Mostrar(MapStrategyCreateDto<AffectedZoneWithPointsDTO> mapStrategyCreateDto) {
            var strategy = await _mapStrategyServices.Mostrar(mapStrategyCreateDto, _iMapServices);
            return Ok(strategy);
        }

        [HttpGet("map/prueba")]

        public IActionResult prueba() {
            return Ok("okay");
        }

    }
}
