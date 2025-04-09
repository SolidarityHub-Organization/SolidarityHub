using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers 
{
    [Route("api/v1")]
    [ApiController]
    public class LoginController : ControllerBase 
    {
        private readonly ILoginServices _LoginServices;

        public LoginController(ILoginServices loginServices) 
        {
            _LoginServices = loginServices;
        }


		[HttpPost("login")]
		public async Task<IActionResult> LogInAsync(LoginDto login) {
			try {
				var res = await _LoginServices.LogInAsync(login.email, login.password);
				if (res == null) {
					return Unauthorized(res);
				}
				return Ok(res);
			} catch (KeyNotFoundException ex) {
				return NotFound(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
	}
}
