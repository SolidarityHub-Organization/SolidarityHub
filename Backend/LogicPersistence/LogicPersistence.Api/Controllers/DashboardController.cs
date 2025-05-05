using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardServices _dashboardServices;

        public DashboardController(IDashboardServices dashboardServices)
        {
            _dashboardServices = dashboardServices;
        }

        [HttpGet("dashboard/activity-log")]
        public async Task<IActionResult> GetActivityLogData([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate)
        {
            try
            {
                var data = await _dashboardServices.GetActivityLogDataAsync(fromDate, toDate);
                return Ok(data);
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