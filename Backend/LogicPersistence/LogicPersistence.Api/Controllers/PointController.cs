using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class PointController : ControllerBase
    {
        private readonly IPointServices _pointServices;

        public PointController(IPointServices pointServices)
        {
            _pointServices = pointServices;
        }

#region PickupPoint
        [HttpPost("pickup-points")]
        public async Task<IActionResult> CreatePickupPointAsync(PickupPointCreateDto pickupPointCreateDto)
        {
            try
            {
                var pickupPoint = await _pointServices.CreatePickupPointAsync(pickupPointCreateDto);
                return CreatedAtRoute(nameof(GetPickupPointByIdAsync), new { id = pickupPoint.id }, pickupPoint);
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("pickup-points/{id}", Name = "GetPickupPointByIdAsync")]
        public async Task<IActionResult> GetPickupPointByIdAsync(int id)
        {
            try
            {
                var pickupPoint = await _pointServices.GetPickupPointByIdAsync(id);
                return Ok(pickupPoint);
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

        [HttpPut("pickup-points/{id}")]
        public async Task<IActionResult> UpdatePickupPointAsync(int id, PickupPointUpdateDto pickupPointUpdateDto)
        {
            try
            {
                var result = await _pointServices.UpdatePickupPointAsync(id, pickupPointUpdateDto);
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

        [HttpGet("pickup-points")]
        public async Task<IActionResult> GetAllPickupPointsAsync()
        {
            try
            {
                var pickups = await _pointServices.GetAllPickupPointsAsync();
                return Ok(pickups);
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
#endregion
#region MeetingPoint
        [HttpPost("meeting-points")]
        public async Task<IActionResult> CreateMeetingPointAsync(MeetingPointCreateDto meetingPointCreateDto)
        {
            try
            {
                var meetingPoint = await _pointServices.CreateMeetingPointAsync(meetingPointCreateDto);
                return CreatedAtRoute(nameof(GetMeetingPointByIdAsync), new { id = meetingPoint.id }, meetingPoint);
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("meeting-points/{id}", Name = "GetMeetingPointByIdAsync")]
        public async Task<IActionResult> GetMeetingPointByIdAsync(int id)
        {
            try
            {
                var meetingPoint = await _pointServices.GetMeetingPointByIdAsync(id);
                return Ok(meetingPoint);
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

        [HttpPut("meeting-points/{id}")]
        public async Task<IActionResult> UpdateMeetingPointAsync(int id, MeetingPointUpdateDto meetingPointUpdateDto)
        {
            try
            {
                var result = await _pointServices.UpdateMeetingPointAsync(id, meetingPointUpdateDto);
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

        [HttpGet("meeting-points")]
        public async Task<IActionResult> GetAllMeetingPointsAsync()
        {
            try
            {
                var meetings = await _pointServices.GetAllMeetingPointsAsync();
                return Ok(meetings);
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
#endregion
        
    }
}