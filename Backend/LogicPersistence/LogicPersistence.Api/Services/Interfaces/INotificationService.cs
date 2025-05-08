using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Services.Interfaces;

public interface INotificationService {
    Task<IEnumerable<Notification>> GetNotificationsForVolunteerAsync(int volunteerId);
    Task<IEnumerable<Notification>> GetNotificationsForVictimAsync(int victimId);
}
