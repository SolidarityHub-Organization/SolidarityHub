using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IMapServices
    {
        Task<IEnumerable<UserLocationDTO>> GetAllVictimsWithLocationAsync();
        Task<IEnumerable<UserLocationDTO>> GetAllVolunteersWithLocationAsync();
        Task<IEnumerable<UserLocationDTO>> GetAllUsersWithLocationAsync();
        Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllAffectedZonesWithPointsAsync();
    }
}