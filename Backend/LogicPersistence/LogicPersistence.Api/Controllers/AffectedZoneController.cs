using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;


namespace LogicPersistence.Api.Controllers 
{

	[Route("api/v1")]
	[ApiController]
    public class AffectedZoneController : ControllerBase
    {
        private readonly IAffectedZoneServices _affectedZoneServices;

        public AffectedZoneController(IAffectedZoneServices affectedZoneServices)
        {
            _affectedZoneServices = affectedZoneServices;
        }

        [HttpPost("affected-zones")]
        public async Task<ActionResult> CreateAffectedZoneAsync(AffectedZoneCreateDto affectedZoneCreateDto)
        {
            try
            {
                var affectedZone = await _affectedZoneServices.CreateAffectedZoneAsync(affectedZoneCreateDto);
                return CreatedAtAction("GetAffectedZoneById", new { id = affectedZone.id }, affectedZone);
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("affected-zones/{id}")]
        public async Task<ActionResult> UpdateAffectedZoneAsync(int id, AffectedZoneUpdateDto affectedZoneUpdateDto)
        {
            try
            {
                var result = await _affectedZoneServices.UpdateAffectedZoneAsync(id, affectedZoneUpdateDto);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("affected-zones/{id}")]
        public async Task<ActionResult> DeleteAffectedZoneAsync(int id)
        {
            try
            {
                await _affectedZoneServices.DeleteAffectedZoneAsync(id);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("affected-zones/{id}")]
        public async Task<ActionResult> GetAffectedZoneByIdAsync(int id)
        {
            try
            {
                var affectedZone = await _affectedZoneServices.GetAffectedZoneByIdAsync(id);
                return Ok(affectedZone);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("affected-zones")]
        public async Task<ActionResult> GetAllAffectedZonesAsync()
        {
            try
            {
                var affectedZones = await _affectedZoneServices.GetAllAffectedZonesAsync();
                return Ok(affectedZones);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
    }

}