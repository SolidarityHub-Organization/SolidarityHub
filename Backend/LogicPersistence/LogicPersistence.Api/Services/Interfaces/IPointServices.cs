using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IPointServices
    {   
        Task<PickupPoint> CreatePickupPointAsync(PickupPointCreateDto pickupPointCreateDto);
        Task<PickupPoint> UpdatePickupPointAsync(int id, PickupPointUpdateDto pickupPointUpdateDto);
        Task<PickupPoint> GetPickupPointByIdAsync(int id);
        Task<IEnumerable<PickupPoint>> GetAllPickupPointsAsync();
        Task<(IEnumerable<PickupPoint> PickupPoints, int TotalCount)> GetPaginatedPickupPointsAsync(int pageNumber, int pageSize);


        Task<MeetingPoint> CreateMeetingPointAsync(MeetingPointCreateDto meetingPointCreateDto);
        Task<MeetingPoint> UpdateMeetingPointAsync(int id, MeetingPointUpdateDto meetingPointUpdateDto);
        Task<MeetingPoint> GetMeetingPointByIdAsync(int id);
        Task<IEnumerable<MeetingPoint>> GetAllMeetingPointsAsync();
        Task<(IEnumerable<MeetingPoint> MeetingPoints, int TotalCount)> GetPaginatedMeetingPointsAsync(int pageNumber, int pageSize);
    }
}