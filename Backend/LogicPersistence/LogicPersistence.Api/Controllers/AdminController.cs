using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers 
{
    [Route("api/v1")]
    [ApiController]
    public class AdminController : ControllerBase {
        private readonly IAdminServices _adminServices;

        public AdminController(IAdminServices adminServices) {
            _adminServices = adminServices;
        }

        [HttpPost("admins")]
        [ActionName(nameof(CreateAdminAsync))]
        public async Task<IActionResult> CreateAdminAsync(AdminCreateDto adminCreateDto) {
            try {
                var admin = await _adminServices.CreateAdminAsync(adminCreateDto);               
                return CreatedAtAction(nameof(CreateAdminAsync), new { id = admin.id }, admin);
            } catch (ArgumentNullException ex) {
                return BadRequest(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("admins/{id}", Name = "GetAdminById")]
        public async Task<IActionResult> GetAdminByIdAsync(int id) {
            try {
                var admin = await _adminServices.GetAdminByIdAsync(id);
                return Ok(admin);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("admins/{id}")]
        public async Task<IActionResult> UpdateAdminAsync(int id, AdminUpdateDto adminUpdateDto) {
            try {
                var result = await _adminServices.UpdateAdminAsync(id, adminUpdateDto);
                return Ok(result);
            } catch (ArgumentException ex) {
                return BadRequest(ex.Message);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("admins/{id}")]
        public async Task<IActionResult> DeleteAdminAsync(int id) {
            try {
                await _adminServices.DeleteAdminAsync(id);
                return NoContent();
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("admins", Name = "GetAllAdmins")]
        public async Task<IActionResult> GetAllAdminsAsync() {
            try {
                var admins = await _adminServices.GetAllAdminsAsync();
                return Ok(admins);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("admins/email/{email}", Name = "GetAdminByEmail")]
        public async Task<IActionResult> GetAdminByEmailAsync(string email) {
            try {
                var admin = await _adminServices.GetAdminByEmailAsync(email);
                return Ok(admin);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("admins/jurisdiction/{jurisdiction}", Name = "GetAdminByJurisdiction")]
        public async Task<IActionResult> GetAdminByJurisdictionAsync(string jurisdiction) {
            try {
                var admin = await _adminServices.GetAdminByJurisdictionAsync(jurisdiction);
                return Ok(admin);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("admins/LogInAdmin/{email},{password}", Name = "LogInAdmin")]
        public async Task<IActionResult> LogInAdminAsync(string email, string password) {
            try {
                var res = await _adminServices.LogInAdminAsync(email, password);
                if (!res.signIn)
                {
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