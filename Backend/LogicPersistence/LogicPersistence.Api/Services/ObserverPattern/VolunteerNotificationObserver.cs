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
            name = $"Nueva tarea: {taskName}",
            description = "Se ha creado una nueva tarea. Ya puedes ver los detalles en la aplicación y aceptarla o rechazarla.",
            volunteer_id = volunteerId,
            created_at = DateTime.UtcNow
        };
        // Save notification (assume async method, but for observer pattern, use fire-and-forget)
        _ = _notificationService.CreateNotificationForVolunteerAsync(notification);
    }
}
