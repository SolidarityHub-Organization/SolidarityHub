using LogicPersistence.Api.Services.Interfaces;
using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Services.ObserverPattern;

public class VolunteerNotificationObserver : ITaskAssignmentObserver {
    private readonly INotificationService _notificationService;

    public VolunteerNotificationObserver(INotificationService notificationService) {
        _notificationService = notificationService;
    }

    public void OnTaskAssigned(int volunteerId, int taskId, string taskName) {
        // Create a notification for the volunteer
        var notification = new Notification {
            name = $"New Task Assigned: {taskName}",
            description = $"You have been assigned a new task (ID: {taskId}).",
            volunteer_id = volunteerId,
            created_at = DateTime.UtcNow
        };
        // Save notification (assume async method, but for observer pattern, use fire-and-forget)
        _ = _notificationService.CreateNotificationForVolunteerAsync(notification);
    }
}
