using LogicPersistence.Api.Models;
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

		[HttpGet("location/affectedplaces/{id}")]
		public async Task<IActionResult> GetPlacesByLocationIdAsync(int id) {
			try {
				var places = await _locationServices.GetAffectedZoneByLocationIdAsync(id);
				return Ok(places);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("locations/paginated")]
		public async Task<IActionResult> GetPaginatedLocationsAsync([FromQuery] int page = 1, [FromQuery] int size = 10)
		{
			try
			{
				var (locations, totalCount) = await _locationServices.GetPaginatedLocationsAsync(page, size);

				var result = new PaginatedResultDto<Location>
				{
					Items = locations,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				};

				return Ok(result);
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

		[HttpPost("affected-zones/{zoneId}/locations")]
		public async Task<IActionResult> CreateLocationsForZoneAsync(int zoneId, [FromBody] IEnumerable<Location> locations)
		{
			var result = await _locationServices.CreateLocationsByAffectedZoneIdAsync(zoneId, locations);
			if (result)
				return Ok();
			return StatusCode(500, "Failed to create locations for the affected zone.");
		}

		[HttpDelete("affected-zones/{zoneId}/locations")]
		public async Task<IActionResult> DeleteLocationsForZoneAsync(int zoneId)
		{
			try
			{
				var result = await _locationServices.DeleteLocationsByAffectedZoneIdAsync(zoneId);
				
				if (result)
					return NoContent(); // 204 No Content - successful deletion
					
				return StatusCode(500, "Failed to delete locations for the affected zone.");
			}
			catch (KeyNotFoundException ex)
			{
				return NotFound(ex.Message); // 404 Not Found
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
