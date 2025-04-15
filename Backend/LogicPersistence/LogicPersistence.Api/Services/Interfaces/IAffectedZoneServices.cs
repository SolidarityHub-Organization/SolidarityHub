using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IAffectedZoneServices
    {
        Task<AffectedZone> CreateAffectedZoneAsync(AffectedZoneCreateDto affectedZoneCreateDto);
        Task<AffectedZone> UpdateAffectedZoneAsync(int id, AffectedZoneUpdateDto affectedZoneUpdateDto);
        System.Threading.Tasks.Task DeleteAffectedZoneAsync(int id);
        Task<AffectedZone> GetAffectedZoneByIdAsync(int id);
        Task<IEnumerable<AffectedZone>> GetAllAffectedZonesAsync();
        Task<IEnumerable<AffectedZoneWithPointsDTO>> GetAllAffectedZonesWithPointsAsync();
    }
}