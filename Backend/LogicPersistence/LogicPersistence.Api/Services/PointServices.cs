using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class PointServices : IPointServices
    {
        private readonly IPointRepository _pointRepository;
        public PointServices(IPointRepository pointRepository)
        {
            _pointRepository = pointRepository;
        }

#region PickupPoint
        public async Task<PickupPoint> CreatePickupPointAsync(PickupPointCreateDto pickupPointCreateDto) 
        {
            if (pickupPointCreateDto == null) {
                throw new ArgumentNullException(nameof(pickupPointCreateDto));
            }

            var pickupPoint = await _pointRepository.CreatePickupPointAsync(pickupPointCreateDto.ToPickupPoint());
            if (pickupPoint == null) {
                throw new InvalidOperationException("Failed to create pickup point.");
            }

            return pickupPoint;
        }

        public async Task<PickupPoint> UpdatePickupPointAsync(int id, PickupPointUpdateDto pickupPointUpdateDto) 
        {
            if (id != pickupPointUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingPickupPoint = await _pointRepository.GetPickupPointByIdAsync(id);
            if (existingPickupPoint == null) {
                throw new KeyNotFoundException($"PickupPoint with id {id} not found.");
            }
            var updatedPickupPoint = pickupPointUpdateDto.ToPickupPoint();
            await _pointRepository.UpdatePickupPointAsync(updatedPickupPoint);
            return updatedPickupPoint;
        }

        public async Task<PickupPoint> GetPickupPointByIdAsync(int id) 
        {
            var pickupPoint = await _pointRepository.GetPickupPointByIdAsync(id);
            if (pickupPoint == null) {
                throw new KeyNotFoundException($"PickupPoint with id {id} not found.");
            }
            return pickupPoint;
        }

        public async Task<IEnumerable<PickupPoint>> GetAllPickupPointsAsync() 
        {
            var pickupPoints = await _pointRepository.GetAllPickupPointsAsync();
            if (pickupPoints == null) {
                throw new KeyNotFoundException($"No PickupPoints found.");
            }
            return pickupPoints;
        }
#endregion
#region MeetingPoint
        public async Task<MeetingPoint> CreateMeetingPointAsync(MeetingPointCreateDto meetingPointCreateDto) 
        {
            if (meetingPointCreateDto == null) {
                throw new ArgumentNullException(nameof(meetingPointCreateDto));
            }

            var meetingPoint = await _pointRepository.CreateMeetingPointAsync(meetingPointCreateDto.ToMeetingPoint());
            if (meetingPoint == null) {
                throw new InvalidOperationException("Failed to create meeting point.");
            }

            return meetingPoint;
        }

        public async Task<MeetingPoint> UpdateMeetingPointAsync(int id, MeetingPointUpdateDto meetingPointUpdateDto) 
        {
            if (id != meetingPointUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingMeetingPoint = await _pointRepository.GetMeetingPointByIdAsync(id);
            if (existingMeetingPoint == null) {
                throw new KeyNotFoundException($"MeetingPoint with id {id} not found.");
            }
            var updatedMeetingPoint = meetingPointUpdateDto.ToMeetingPoint();
            await _pointRepository.UpdateMeetingPointAsync(updatedMeetingPoint);
            return updatedMeetingPoint;
        }

        public async Task<MeetingPoint> GetMeetingPointByIdAsync(int id) 
        {
            var meetingPoint = await _pointRepository.GetMeetingPointByIdAsync(id);
            if (meetingPoint == null) {
                throw new KeyNotFoundException($"MeetingPoint with id {id} not found.");
            }
            return meetingPoint;
        }

        public async Task<IEnumerable<MeetingPoint>> GetAllMeetingPointsAsync() 
        {
            var meetingPoints = await _pointRepository.GetAllMeetingPointsAsync();
            if (meetingPoints == null) {
                throw new KeyNotFoundException($"No MeetingPoints found.");
            }
            return meetingPoints;
        }
#endregion
    }
}
