using LogicPersistence.Api.Models;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LogicPersistence.Api.Controllers;

[Route("api/v1")]
[ApiController]
public class NotificationController : ControllerBase {
    private readonly NotificationService _notificationService;

    public NotificationController() {
        _notificationService = new NotificationService();
    }

    // Endpoint to get notifications assigned to a volunteer
    [HttpGet("notifications/volunteer/{volunteerId}")]
    public async Task<IActionResult> GetNotificationsForVolunteerAsync(int volunteerId) {
        try {
            var notifications = await _notificationService.GetNotificationsForVolunteerAsync(volunteerId);
            return Ok(notifications);
        } catch (ArgumentException ex) {
            return BadRequest(ex.Message);
        } catch (Exception ex) {
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }
    }

    // Endpoint to get notifications assigned to a victim
    [HttpGet("notifications/victim/{victimId}")]
    public async Task<IActionResult> GetNotificationsForVictimAsync(int victimId) {
        try {
            var notifications = await _notificationService.GetNotificationsForVictimAsync(victimId);
            return Ok(notifications);
        } catch (ArgumentException ex) {
            return BadRequest(ex.Message);
        } catch (Exception ex) {
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }
    }
}
