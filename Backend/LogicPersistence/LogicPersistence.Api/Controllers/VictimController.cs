using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

// The controller is the entry point for the API. It is responsible for handling the incoming HTTP requests and sending the response back to the client.
// It must be attached to the service to be able to perform the necessary operations on the database, and to use the application's logic.

namespace LogicPersistence.Api.Controllers {

	[Route("api/v1")]
	[ApiController]
	public class VictimController : ControllerBase {
		private readonly IVictimServices _victimServices;

		public VictimController(IVictimServices victimServices) {
			_victimServices = victimServices;
		}

		[HttpPost("victim")]
		public async Task<IActionResult> CreateVictim(VictimCreateDto victimCreateDto) {
			try {
				var victim = await _victimServices.CreateVictim(victimCreateDto);
				return CreatedAtRoute(nameof(GetVictimByIdAsync), new { id = victim.id }, victim);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		fgcfc

		[HttpGet("victim/{id}", Name = "GetVictimById")]
		public async Task<IActionResult> GetVictimByIdAsync(int id) {
			try {
				var victim = await _victimServices.GetVictimByIdAsync(id);
				return Ok(victim);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("victim/{id}")]
		public async Task<IActionResult> UpdateVictimAsync(int id, VictimUpdateDto victimUpdateDto) {
			try {
				var result = await _victimServices.UpdateVictimAsync(id, victimUpdateDto);
				return Ok(result);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpDelete("victim/{id}")]
		public async Task<IActionResult> DeleteVictimAsync(int id) {
			try {
				await _victimServices.DeleteVictimAsync(id);
				return NoContent();
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("victims")]
		public async Task<IActionResult> GetVictims() {
			try {
				var victims = await _victimServices.GetVictimsAsync();
				return Ok(victims);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
	}
}
