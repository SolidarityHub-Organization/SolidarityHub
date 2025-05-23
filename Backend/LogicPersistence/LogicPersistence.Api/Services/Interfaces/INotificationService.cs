using LogicPersistence.Api.Models;
using System.Threading.Tasks;

namespace LogicPersistence.Api.Services.Interfaces;

public interface INotificationService {
    Task<IEnumerable<Notification>> GetNotificationsForVolunteerAsync(int volunteerId);
    Task<IEnumerable<Notification>> GetNotificationsForVictimAsync(int victimId);
    System.Threading.Tasks.Task CreateNotificationForVolunteerAsync(Notification notification);
}
