using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class SkillController : ControllerBase {
        private readonly ISkillServices _skillServices;

        public SkillController(ISkillServices skillServices) {
            _skillServices = skillServices;
        }

        [HttpPost("skills")]
        public async Task<IActionResult> CreateSkillAsync(SkillCreateDto skillCreateDto) {
            try {
                var skill = await _skillServices.CreateSkillAsync(skillCreateDto);
                return CreatedAtRoute(nameof(GetSkillByIdAsync), new { id = skill.id }, skill);
            } catch (ArgumentNullException ex) {
                return BadRequest(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("skills/{id}", Name = "GetSkillByIdAsync")]
        public async Task<IActionResult> GetSkillByIdAsync(int id) {
            try {
                var skill = await _skillServices.GetSkillByIdAsync(id);
                return Ok(skill);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("skills/{id}")]
        public async Task<IActionResult> UpdateSkillAsync(int id, SkillUpdateDto skillUpdateDto) {
            try {
                var result = await _skillServices.UpdateSkillAsync(id, skillUpdateDto);
                return Ok(result);
            } catch (ArgumentException ex) {
                return BadRequest(ex.Message);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("skills/{id}")]
        public async Task<IActionResult> DeleteSkillAsync(int id) {
            try {
                await _skillServices.DeleteSkillAsync(id);
                return NoContent();
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("skills")]
        public async Task<IActionResult> GetAllSkillsAsync() {
            try {
                var skills = await _skillServices.GetAllSkillsAsync();
                return Ok(skills);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("skills/volunteer-counts")]
        public async Task<IActionResult> GetSkillsWithVolunteerCountAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var skillsWithVolunteerCount = await _skillServices.GetSkillsWithVolunteerCountAsync(fromDate, toDate);
                return Ok(skillsWithVolunteerCount);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
        
        [HttpGet("skills/paginated")]
		public async Task<IActionResult> GetPaginatedSkillsAsync([FromQuery] int page = 1, [FromQuery] int size = 10)
		{
			try
			{
				var (skills, totalCount) = await _skillServices.GetPaginatedSkillsAsync(page, size);

				return Ok(new
				{
					Items = skills,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				});
			}
			catch (ArgumentException ex)
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
    }
}