using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers 
{
    [Route("api/v1")]
    [ApiController]
    public class VolunteerController : ControllerBase 
    {
        private readonly IVolunteerServices _volunteerServices;

        public VolunteerController(IVolunteerServices volunteerServices) 
        {
            _volunteerServices = volunteerServices;
        }

        [HttpPost("volunteers")]
        public async Task<IActionResult> CreateVolunteerAsync(VolunteerCreateDto volunteerCreateDto) 
        {
            try 
            {
                var volunteer = await _volunteerServices.CreateVolunteerAsync(volunteerCreateDto);
                return CreatedAtRoute(nameof(GetVolunteerByIdAsync), new { id = volunteer.id }, volunteer);
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

        [HttpGet("volunteers/{id}", Name = "GetVolunteerById")]
        public async Task<IActionResult> GetVolunteerByIdAsync(int id) 
        {
            try 
            {
                var volunteer = await _volunteerServices.GetVolunteerByIdAsync(id);
                return Ok(volunteer);
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

        [HttpPut("volunteers/{id}")]
        public async Task<IActionResult> UpdateVolunteerAsync(int id, VolunteerUpdateDto volunteerUpdateDto) 
        {
            try 
            {
                var result = await _volunteerServices.UpdateVolunteerAsync(id, volunteerUpdateDto);
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

        [HttpDelete("volunteers/{id}")]
        public async Task<IActionResult> DeleteVolunteerAsync(int id) 
        {
            try 
            {
                await _volunteerServices.DeleteVolunteerAsync(id);
                return NoContent();
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

        [HttpGet("volunteers")]
        public async Task<IActionResult> GetAllVolunteersAsync() 
        {
            try 
            {
                var volunteers = await _volunteerServices.GetAllVolunteersAsync();
                return Ok(volunteers);
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

        [HttpGet("volunteers/email/{email}")]
        public async Task<IActionResult> GetVolunteerByEmailAsync(string email) 
        {
            try 
            {
                var volunteer = await _volunteerServices.GetVolunteerByEmailAsync(email);
                return Ok(volunteer);
            }
            catch (ArgumentNullException ex) 
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
    }
}