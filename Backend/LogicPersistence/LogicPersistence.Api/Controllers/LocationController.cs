using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;


namespace LogicPersistence.Api.Controllers {

	[Route("api/v1")]
	[ApiController]
	public class LocationController(ILocationServices locationServices) : ControllerBase {
		private readonly ILocationServices _locationServices = locationServices;

		[HttpPost("locations")]
		public async Task<IActionResult> CreateLocationAsync(LocationCreateDto locationCreateDto) {
			try {
				var location = await _locationServices.CreateLocationAsync(locationCreateDto);
				return CreatedAtRoute("GetLocationById", new { id = location.id }, location);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("locations/{id}", Name = "GetLocationById")]
		public async Task<IActionResult> GetLocationByIdAsync(int id) {
			try {
				var location = await _locationServices.GetLocationByIdAsync(id);
				return Ok(location);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("locations/{id}")]
		public async Task<IActionResult> UpdateLocationAsync(int id, LocationUpdateDto taskUpdateDto) {
			try {
				var result = await _locationServices.UpdateLocationAsync(id, taskUpdateDto);
				return Ok(result);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpDelete("locations/{id}")]
		public async Task<IActionResult> DeleteLocationAsync(int id) {
			try {
				await _locationServices.DeleteLocationAsync(id);
				return NoContent();
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("locations")]
		public async Task<IActionResult> GetAllLocationsAsync() {
			try {
				var locations = await _locationServices.GetAllLocationsAsync();
				return Ok(locations);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("locations/victims-with-location")]
		public async Task<IActionResult> GetAllVictimsWithLocationAsync()
		{
			try
			{
				var victimsWithLocation = await _locationServices.GetAllVictimsWithLocationAsync();
				return Ok(victimsWithLocation);
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

		[HttpGet("locations/volunteers-with-location")]
		public async Task<IActionResult> GetAllVolunteersWithLocationAsync()
		{
			try
			{
				var volunteerWithLocation = await _locationServices.GetAllVolunteersWithLocationAsync();
				return Ok(volunteerWithLocation);
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

		[HttpGet("locations/users-with-location")]
		public async Task<IActionResult> GetAllUsersWithLocationAsync()
		{
			try
			{
				var usersWithLocation = await _locationServices.GetAllUsersWithLocationAsync();
				return Ok(usersWithLocation);
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
