using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class VolunteerSkillController : ControllerBase
    {
        private readonly IVolunteerSkillServices _volunteerSkillServices;

        public VolunteerSkillController(IVolunteerSkillServices volunteerSkillServices)
        {
            _volunteerSkillServices = volunteerSkillServices;
        }

        [HttpPost("volunteerSkills")]
        public async Task<IActionResult> CreateVolunteerSkillAsync(VolunteerSkillCreateDto volunteerSkillCreateDto)
        {
            try
            {
                var volunteerSkill = await _volunteerSkillServices.CreateVolunteerSkillAsync(volunteerSkillCreateDto);
                return CreatedAtRoute(nameof(GetVolunteerSkillByIdAsync), new { volunteer_id = volunteerSkill.skill_id, skill_id = volunteerSkill.volunteer_id }, volunteerSkill);
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

        [HttpGet("volunteerSkills/{volunteer_id}/{skill_id}", Name = "GetVolunteerSkillByIdAsync")]
        public async Task<IActionResult> GetVolunteerSkillByIdAsync(int volunteer_id, int skill_id)
        {
            try
            {
                var volunteerSkill = await _volunteerSkillServices.GetVolunteerSkillByIdAsync(volunteer_id, skill_id);
                return Ok(volunteerSkill);
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

        [HttpPut("volunteerSkills/{volunteer_id}/{skill_id}")]
        public async Task<IActionResult> UpdateVolunteerSkillAsync(int volunteer_id, int skill_id, VolunteerSkillUpdateDto volunteerSkillUpdateDto)
        {
            try
            {
                var result = await _volunteerSkillServices.UpdateVolunteerSkillAsync(volunteer_id, skill_id, volunteerSkillUpdateDto);
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

        [HttpDelete("volunteerSkills/{volunteer_id}/{skill_id}")]
        public async Task<IActionResult> DeleteVolunteerSkillAsync(int volunteer_id, int skill_id)
        {
            try
            {
                await _volunteerSkillServices.DeleteVolunteerSkillAsync(volunteer_id, skill_id);
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

        [HttpGet("volunteerSkills")]
        public async Task<IActionResult> GetAllVolunteerSkillsAsync()
        {
            try
            {
                var volunteerSkills = await _volunteerSkillServices.GetAllVolunteerSkillsAsync();
                return Ok(volunteerSkills);
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