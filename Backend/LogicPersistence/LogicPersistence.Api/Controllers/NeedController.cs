using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers {
	[Route("api/v1")]
	[ApiController]
	public class NeedController : ControllerBase {
		private readonly INeedServices _needServices;

		public NeedController(INeedServices needService) {
			_needServices = needService;
		}

		#region Needs
		[HttpPost("needs")]
		public async Task<IActionResult> CreateNeedAsync(NeedCreateDto needCreateDto) {
			try {
				var need = await _needServices.CreateNeedAsync(needCreateDto);
				return CreatedAtRoute(nameof(GetNeedByIdAsync), new { id = need.id }, need);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs/{id}", Name = "GetNeedByIdAsync")]
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

		[HttpGet("needs/victim/{id}", Name = "GetNeedByVictimIdAsync")]
		public async Task<IActionResult> GetNeedByVictimIdAsync(int id) {
			try {
				var need = await _needServices.GetNeedByVictimIdAsync(id);
				return Ok(need);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("needs/{id}")]
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

		[HttpDelete("needs/{id}")]
		public async Task<IActionResult> DeleteNeedAsync(int id) {
			try {
				await _needServices.DeleteNeedAsync(id);
				return NoContent();
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs")]
		public async Task<IActionResult> GetAllNeedsAsync() {
			try {
				var needs = await _needServices.GetAllNeedsAsync();
				return Ok(needs);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs/victim-details/{id}")]
		public async Task<IActionResult> GetNeedWithVictimDetailsAsync(int id) {
			try {
				var needs = await _needServices.GetNeedWithVictimDetailsAsync(id);
				return Ok(needs);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("needs/status/{id}")]
		public async Task<IActionResult> UpdateNeedStatusAsync(int id, UpdateNeedStatusDto updateNeedStatusDto) {
			try {
				var result = await _needServices.UpdateNeedStatusAsync(id, updateNeedStatusDto);
				return Ok(result);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs/for-volunteer")]
		public async Task<IActionResult> GetNeedsInProgressForVolunteers() {
			try {
				var result = await _needServices.GetNeedsInProgressForVolunteersAsync();
				return Ok(result);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("needs/paginated")]
		public async Task<IActionResult> GetPaginatedNeedsAsync([FromQuery] int page = 1, [FromQuery] int size = 10) {
			try {
				var (needs, totalCount) = await _needServices.GetPaginatedNeedsAsync(page, size);

				return Ok(new {
					Items = needs,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				});
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		#endregion
		#region NeedTypes
		[HttpPost("need-types")]
		public async Task<IActionResult> CreateNeedTypeAsync(NeedTypeCreateDto needTypeCreateDto) {
			try {
				var needType = await _needServices.CreateNeedTypeAsync(needTypeCreateDto);
				return CreatedAtRoute(nameof(GetNeedTypeByIdAsync), new { id = needType.id }, needType);
			} catch (ArgumentNullException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need-types/{id}", Name = "GetNeedTypeByIdAsync")]
		public async Task<IActionResult> GetNeedTypeByIdAsync(int id) {
			try {
				var needType = await _needServices.GetNeedTypeByIdAsync(id);
				return Ok(needType);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpPut("need-types/{id}")]
		public async Task<IActionResult> UpdateNeedTypeAsync(int id, NeedTypeUpdateDto needTypeUpdateDto) {
			try {
				var result = await _needServices.UpdateNeedTypeAsync(id, needTypeUpdateDto);
				return Ok(result);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpDelete("need-types/{id}")]
		public async Task<IActionResult> DeleteNeedTypeAsync(int id) {
			try {
				await _needServices.DeleteNeedTypeAsync(id);
				return NoContent();
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need-types")]
		public async Task<IActionResult> GetAllNeedTypesAsync() {
			try {
				var needTypes = await _needServices.GetAllNeedTypesAsync();
				return Ok(needTypes);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need-types/{id}/victim-count")]
		public async Task<IActionResult> GetVictimCountByIdAsync(int id) {
			try {
				var count = await _needServices.GetVictimCountByIdAsync(id);
				return Ok(count);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need-types/victim-counts")]
		public async Task<IActionResult> GetNeedTypesWithVictimCountAsync() {
			try {
				var needTypesWithVictimCount = await _needServices.GetNeedTypesWithVictimCountAsync();
				return Ok(needTypesWithVictimCount);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("need-types/victim-counts/filtered")]
		public async Task<IActionResult> GetNeedTypesWithVictimCountFilteredByDateAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
			try {
				var needTypesWithVictimCount = await _needServices.GetNeedTypesWithVictimCountAsync(fromDate, toDate);
				return Ok(needTypesWithVictimCount);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
		
		[HttpGet("need-types/paginated")]
		public async Task<IActionResult> GetPaginatedNeedTypesAsync([FromQuery] int page = 1, [FromQuery] int size = 10)
		{
			try
			{
				var (needTypes, totalCount) = await _needServices.GetPaginatedNeedTypesAsync(page, size);

				return Ok(new
				{
					Items = needTypes,
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
		#endregion
	}
}
