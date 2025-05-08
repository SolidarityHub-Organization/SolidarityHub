using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
	[ApiController]
    public class MapController(IMapServices mapServices) : ControllerBase {
        private readonly IMapServices _mapServices = mapServices;

        [HttpGet("map/victims-with-location")]
		public async Task<IActionResult> GetAllVictimsWithLocationAsync()
		{
			try
			{
				var victimsWithLocation = await _mapServices.GetAllVictimsWithLocationAsync();
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

		[HttpGet("map/volunteers-with-location")]
		public async Task<IActionResult> GetAllVolunteersWithLocationAsync()
		{
			try
			{
				var volunteerWithLocation = await _mapServices.GetAllVolunteersWithLocationAsync();
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

		[HttpGet("map/users-with-location")]
		public async Task<IActionResult> GetAllUsersWithLocationAsync()
		{
			try
			{
				var usersWithLocation = await _mapServices.GetAllUsersWithLocationAsync();
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

        [HttpGet("map/affected-zones-with-points")]
        public async Task<ActionResult> GetAllAffectedZonesWithPointsAsync()
        {
            try
            {
                var affectedZones = await _mapServices.GetAllAffectedZonesWithPointsAsync();
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

		[HttpGet("map/tasks-with-location")]
		public async Task<IActionResult> GetAllTasksWithLocationAsync()
		{
			try
			{
				var tasksWithLocation = await _mapServices.GetAllTasksWithLocationAsync();
				return Ok(tasksWithLocation);
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

		[HttpGet("map/risk-zones-with-points")]
		public async Task<ActionResult> GetAllRiskZonesWithPointsAsync()
		{
			try
			{
				var riskZones = await _mapServices.GetAllRiskZonesWithPointsAsync();
				return Ok(riskZones);
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

		[HttpGet("map/pickup-points-with-location")]
		public async Task<IActionResult> GetAllPickupPointsWithLocationAsync()
		{
			try
			{
				var pickupPointsWithLocation = await _mapServices.GetAllPickupPointsWithLocationAsync();
				return Ok(pickupPointsWithLocation);
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

		[HttpGet("map/meeting-points-with-location")]
		public async Task<IActionResult> GetAllMeetingPointsWithLocationAsync()
		{
			try
			{
				var meetingPointsWithLocation = await _mapServices.GetAllMeetingPointsWithLocationAsync();
				return Ok(meetingPointsWithLocation);
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
