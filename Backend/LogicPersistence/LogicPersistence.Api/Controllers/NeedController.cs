/*using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;

namespace LogicPersistence.Api.Controllers {
	public class NeedController : ControllerBase {
		private readonly INeedServices _needServices;

		public NeedController(INeedServices needServices) {
			_needServices = needServices;
		}

		[HttpPost("need")]
		public async Task<IActionResult> CreateNeed(NeedCreateDto needCreateDto) {
			try {
				var need = await _needServices.CreateNeed(needCreateDto);
				return CreatedAtRoute(nameof(GetNeedByIdAsync), new { id = need.id }, need);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need/{id}", Name = "GetNeedById")]
		public async Task<IActionResult> GetNeedByIdAsync(int id) {
			try {
				var need = await _needServices.GetNeedByIdAsync(id);
				return Ok(need);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("need/{id}")]
		public async Task<IActionResult> UpdateNeedAsync(int id, NeedUpdateDto needUpdateDto) {
			try {
				var result = await _needServices.UpdateNeedAsync(id, needUpdateDto);
				return Ok(result);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpDelete("need/{id}")]
		public async Task<IActionResult> DeleteNeedAsync(int id) {
			try {
				var result = await _needServices.DeleteNeedAsync(id);
				return Ok(result);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs")]
		public async Task<IActionResult> GetNeeds() {
			try {
				var needs = await _needServices.GetNeedsAsync();
				return Ok(needs);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
	}
}*/
