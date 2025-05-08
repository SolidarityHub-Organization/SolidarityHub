using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IMapServices
    {
        Task<IEnumerable<MapMarkerDTO>> GetAllVictimsWithLocationAsync();
        Task<IEnumerable<MapMarkerDTO>> GetAllVolunteersWithLocationAsync();
        Task<IEnumerable<MapMarkerDTO>> GetAllUsersWithLocationAsync();
        Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllAffectedZonesWithPointsAsync();
        Task<IEnumerable<MapMarkerDTO>> GetAllTasksWithLocationAsync();
        Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllRiskZonesWithPointsAsync();
        Task<IEnumerable<PickupPointMapMarkerDTO>> GetAllPickupPointsWithLocationAsync();
        Task<IEnumerable<MeetingPointMapMarkerDTO>> GetAllMeetingPointsWithLocationAsync();
    }
}