/*using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace LogicPersistence.Api.Controllers {
	[Route("api/v1")]
	[ApiController]
	public class SkillController : ControllerBase {
		private readonly ISkillServices _skillServices;

		public SkillController(ISkillServices skillServices) {
			_skillServices = skillServices;
		}

		[HttpPost("skill")]
		public async Task<IActionResult> CreateSkill(SkillCreateDto skillCreateDto) {
			try {
				var skill = await _skillServices.CreateSkill(skillCreateDto);
				return CreatedAtRoute(nameof(GetSkillByIdAsync), new { id = skill.id }, skill);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("skill/{id}", Name = "GetSkillById")]
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

		[HttpPut("skill/{id}")]
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

		[HttpDelete("skill/{id}")]
		public async Task<IActionResult> DeleteSkillAsync(int id) {
			try {
				await _skillServices.DeleteSkillAsync(id);
				return NoContent();
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("skill")]
		public async Task<IActionResult> GetSkills() {
			try {
				var skills = await _skillServices.GetSkillsAsync();
				return Ok(skills);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
	}
}*/
