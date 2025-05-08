using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Repositories.Interfaces;
using System.Data;

namespace LogicPersistence.Api.Repositories;

public class PointRepository : IPointRepository {
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

#region PickupPoint
    public async Task<PickupPoint> CreatePickupPointAsync(PickupPoint pickupPoint) 
    {
        return null;
    }

    public async Task<PickupPoint> UpdatePickupPointAsync(PickupPoint pickupPoint) 
    {
        return null;
    }

    public async Task<PickupPoint> GetPickupPointByIdAsync(int id) 
    {
        return null;
    }

    public async Task<IEnumerable<PickupPoint>> GetAllPickupPointsAsync() 
    {
        return null;
    }

    public async Task<IEnumerable<PhysicalDonation>> GetPhysicalDonationsByPickupPointIdAsync(int id) 
    {
        return null;
    }
#endregion

#region MeetingPoint
    public async Task<MeetingPoint> CreateMeetingPointAsync(MeetingPoint meetingPoint) 
    {
        return null;
    }

    public async Task<MeetingPoint> UpdateMeetingPointAsync(MeetingPoint meetingPoint) 
    {
        return null;
    }

    public async Task<MeetingPoint> GetMeetingPointByIdAsync(int id) 
    {
        return null;
    }

    public async Task<IEnumerable<MeetingPoint>> GetAllMeetingPointsAsync() 
    {
        return null;
    }

    public async Task<IEnumerable<Volunteer>> GetVolunteersByMeetingPointIdAsync(int id) 
    {
        return null;
    }
#endregion
}