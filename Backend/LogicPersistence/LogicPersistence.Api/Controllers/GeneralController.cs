using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;


namespace LogicPersistence.Api.Controllers {

	[Route("api/v1")]
	[ApiController]
	public class GeneralController(IGeneralServices generalServices) : ControllerBase {
		private readonly IGeneralServices _generalServices = generalServices;

		[HttpPost("database/populate")]
		public async Task<IActionResult> PopulateDatabaseAsync() {
			try {
				await _generalServices.PopulateDatabaseAsync();
				return Ok("Database populated successfully");
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpDelete("database")]
		public async Task<IActionResult> ClearDatabaseAsync() {
			try {
				await _generalServices.ClearDatabaseAsync();
				return Ok("Database cleared successfully");
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
	}
}
