using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces
{
    public interface IPointRepository
    {
#region PickupPoint
        Task<PickupPoint> CreatePickupPointAsync(PickupPoint pickupPoint);
        Task<PickupPoint> UpdatePickupPointAsync(PickupPoint pickupPoint);
        Task<PickupPoint?> GetPickupPointByIdAsync(int id);
        Task<IEnumerable<PickupPoint>> GetAllPickupPointsAsync();
        Task<IEnumerable<PhysicalDonation>> GetPhysicalDonationsByPickupPointIdAsync(int id);
#endregion
#region MeetingPoint
        Task<MeetingPoint> CreateMeetingPointAsync(MeetingPoint meetingPoint);
        Task<MeetingPoint> UpdateMeetingPointAsync(MeetingPoint meetingPoint);
        Task<MeetingPoint?> GetMeetingPointByIdAsync(int id);
        Task<IEnumerable<MeetingPoint>> GetAllMeetingPointsAsync();
        Task<IEnumerable<Volunteer>> GetVolunteersByMeetingPointIdAsync(int id);
#endregion
    }
}