using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class DonationController : ControllerBase {
        private readonly IDonationServices _donationServices;

        public DonationController(IDonationServices donationServices) {
            _donationServices = donationServices;
        }

        #region PhysicalDonation
        [HttpPost("physical-donations")]
        public async Task<IActionResult> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto) {
            try {
                if (donationCreateDto == null) {
                    return BadRequest("La información de la donación no puede estar vacía.");
                }

                if (!donationCreateDto.volunteer_id.HasValue && !donationCreateDto.admin_id.HasValue) {
                    return BadRequest("Se requiere especificar un volunteer_id o admin_id para crear una donación.");
                }

                var donation = await _donationServices.CreatePhysicalDonationAsync(donationCreateDto);
                return CreatedAtRoute(nameof(GetPhysicalDonationByIdAsync), new { id = donation.id }, donation);
            } catch (ArgumentNullException ex) {
                return BadRequest(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/{id}", Name = "GetPhysicalDonationByIdAsync")]
        public async Task<IActionResult> GetPhysicalDonationByIdAsync(int id) {
            try {
                var donation = await _donationServices.GetPhysicalDonationByIdAsync(id);
                return Ok(donation);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("physical-donations/{id}")]
        public async Task<IActionResult> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto) {
            try {
                var result = await _donationServices.UpdatePhysicalDonationAsync(id, donationUpdateDto);
                return Ok(result);
            } catch (ArgumentException ex) {
                return BadRequest(ex.Message);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("physical-donations/{id}")]
        public async Task<IActionResult> DeletePhysicalDonationAsync(int id) {
            try {
                await _donationServices.DeletePhysicalDonationAsync(id);
                return NoContent();
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations")]
        public async Task<IActionResult> GetAllPhysicalDonationsAsync() {
            try {
                var donations = await _donationServices.GetAllPhysicalDonationsAsync();
                return Ok(donations);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/total-amount")]
        public async Task<IActionResult> GetTotalAmountPhysicalDonationsAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var totalAmount = await _donationServices.GetTotalAmountPhysicalDonationsAsync(fromDate, toDate);
                return Ok(totalAmount);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPost("physical-donations/{id}/assign")]
        public async Task<IActionResult> AssignPhysicalDonationAsync(int id, [FromBody] AssignDonationDto assignDto) {
            try {
                var donation = await _donationServices.GetPhysicalDonationByIdAsync(id);
                if (donation == null) {
                    return NotFound($"Donación con id {id} no encontrada.");
                }

                var updateDto = new PhysicalDonationUpdateDto {
                    id = donation.id,
                    item_name = donation.item_name,
                    description = donation.description,
                    quantity = donation.quantity,
                    item_type = donation.item_type,
                    volunteer_id = donation.volunteer_id,
                    admin_id = donation.admin_id,
                    victim_id = assignDto.victim_id
                };

                var result = await _donationServices.UpdatePhysicalDonationAsync(id, updateDto);
                return Ok(result);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPost("physical-donations/{id}/unassign")]
        public async Task<IActionResult> UnassignPhysicalDonationAsync(int id) {
            try {
                var donation = await _donationServices.GetPhysicalDonationByIdAsync(id);
                if (donation == null) {
                    return NotFound("Donation not found");
                }

                var updatedDonation = await _donationServices.UnassignPhysicalDonationAsync(id);
                return Ok(updatedDonation);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/total-by-type")]
        public async Task<IActionResult> GetPhysicalDonationsTotalAmountByTypeAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donationsCount = await _donationServices.GetPhysicalDonationsTotalAmountByTypeAsync(fromDate, toDate);
                return Ok(donationsCount);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/count-by-type")]
        public async Task<IActionResult> GetPhysicalDonationsCountByTypeAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donationsCount = await _donationServices.GetPhysicalDonationsCountByTypeAsync(fromDate, toDate);
                return Ok(donationsCount);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/by-date")]
        public async Task<IActionResult> GetPhysicalDonationsByDateAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donations = await _donationServices.GetPhysicalDonationsByDateAsync(fromDate, toDate);
                return Ok(donations);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("physical-donations/paginated")]
        public async Task<IActionResult> GetPaginatedPhysicalDonationsAsync([FromQuery] int page = 1, [FromQuery] int size = 10) {
            try {
                var (physicalDonations, totalCount) = await _donationServices.GetPaginatedPhysicalDonationsAsync(page, size);

                return Ok(new {
                    Items = physicalDonations,
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

        [HttpGet("physical-donations/sum-by-week")]
        public async Task<IActionResult> GetPhysicalDonationsSumByWeekAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donationsSum = await _donationServices.GetPhysicalDonationsSumByWeekAsync(fromDate, toDate);
                return Ok(donationsSum);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        #endregion
        #region MonetaryDonation
        [HttpPost("monetary-donations")]
        public async Task<IActionResult> CreateMonetaryDonationAsync(MonetaryDonationCreateDto donationCreateDto) {
            try {
                var donation = await _donationServices.CreateMonetaryDonationAsync(donationCreateDto);
                return CreatedAtRoute(nameof(GetMonetaryDonationByIdAsync), new { id = donation.id }, donation);
            } catch (ArgumentNullException ex) {
                return BadRequest(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations/{id}", Name = "GetMonetaryDonationByIdAsync")]
        public async Task<IActionResult> GetMonetaryDonationByIdAsync(int id) {
            try {
                var donation = await _donationServices.GetMonetaryDonationByIdAsync(id);
                return Ok(donation);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("monetary-donations/{id}")]
        public async Task<IActionResult> UpdateMonetaryDonationAsync(int id, MonetaryDonationUpdateDto donationUpdateDto) {
            try {
                var result = await _donationServices.UpdateMonetaryDonationAsync(id, donationUpdateDto);
                return Ok(result);
            } catch (ArgumentException ex) {
                return BadRequest(ex.Message);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("monetary-donations/{id}")]
        public async Task<IActionResult> DeleteMonetaryDonationAsync(int id) {
            try {
                await _donationServices.DeleteMonetaryDonationAsync(id);
                return NoContent();
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations")]
        public async Task<IActionResult> GetAllMonetaryDonationsAsync() {
            try {
                var donations = await _donationServices.GetAllMonetaryDonationsAsync();
                return Ok(donations);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations/total-amount")]
        public async Task<IActionResult> GetTotalAmountMonetaryDonationsAsync(Currency currency, DateTime fromDate, DateTime toDate) {
            try {
                var totalAmount = await _donationServices.GetTotalMonetaryAmountByCurrencyAsync(currency, fromDate, toDate);
                return Ok(totalAmount);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations/by-date")]
        public async Task<IActionResult> GetMonetaryDonationsByDateAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donations = await _donationServices.GetMonetaryDonationsByDateAsync(fromDate, toDate);
                return Ok(donations);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations/sum-by-week")]
        public async Task<IActionResult> GetMonetaryDonationsSumByWeekAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var donationsSum = await _donationServices.GetMonetaryDonationsSumByWeekAsync(fromDate, toDate);
                return Ok(donationsSum);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
        #endregion
        #region Other methods
        [HttpGet("donations/total-donors")]
        public async Task<IActionResult> GetTotalDonorsAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
            try {
                var totalDonors = await _donationServices.GetTotalAmountDonorsAsync(fromDate, toDate);
                return Ok(totalDonors);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("monetary-donations/paginated")]
        public async Task<IActionResult> GetPaginatedMonetaryDonationsAsync([FromQuery] int page = 1, [FromQuery] int size = 10) {
            try {
                var (monetaryDonations, totalCount) = await _donationServices.GetPaginatedMonetaryDonationsAsync(page, size);

                return Ok(new {
                    Items = monetaryDonations,
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
    }
}