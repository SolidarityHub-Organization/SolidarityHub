using LogicPersistence.Api.Logic;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers 
{
    [Route("api/v1")]
    [ApiController]
    public class SignupController : ControllerBase 
    {
        private readonly ISignupServices _SignupServices;

        public SignupController(ISignupServices SignupServices) 
        {
            _SignupServices = SignupServices;
        }


		[HttpPost("signup")]
		public async Task<IActionResult> SignupAsync(SignupDto login) {
			try {
				var res = await UserFactory.CreateUser(login).Save(_SignupServices);
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
