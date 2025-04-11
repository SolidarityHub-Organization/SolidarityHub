using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class DonationController : ControllerBase
    {
        private readonly IDonationServices _donationServices;

        public DonationController(IDonationServices donationServices)
        {
            _donationServices = donationServices;
        }

#region PhysicalDonation
        [HttpPost("physical-donations")]
        public async Task<IActionResult> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto)
        {
            try
            {
                var donation = await _donationServices.CreatePhysicalDonationAsync(donationCreateDto);
                return CreatedAtRoute(nameof(GetPhysicalDonationByIdAsync), new { id = donation.id }, donation);
            }
            catch (ArgumentNullException ex)
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

        [HttpGet("physical-donations/{id}", Name = "GetPhysicalDonationByIdAsync")]
        public async Task<IActionResult> GetPhysicalDonationByIdAsync(int id)
        {
            try
            {
                var donation = await _donationServices.GetPhysicalDonationByIdAsync(id);
                return Ok(donation);
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

        [HttpPut("physical-donations/{id}")]
        public async Task<IActionResult> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto)
        {
            try
            {
                var result = await _donationServices.UpdatePhysicalDonationAsync(id, donationUpdateDto);
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

        [HttpDelete("physical-donations/{id}")]
        public async Task<IActionResult> DeletePhysicalDonationAsync(int id)
        {
            try
            {
                await _donationServices.DeletePhysicalDonationAsync(id);
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

        [HttpGet("physical-donations")]
        public async Task<IActionResult> GetAllPhysicalDonationsAsync()
        {
            try
            {
                var donations = await _donationServices.GetAllPhysicalDonationsAsync();
                return Ok(donations);
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
#region MonetaryDonation
#endregion
    }
}