using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Repositories.Interfaces
{
    public interface INeedRepository
    {
#region Need
        Task<Need> CreateNeedAsync(Need need);
        Task<bool> DeleteNeedAsync(int id);
        Task<Need?> GetNeedByIdAsync(int id);
        Task<Need> UpdateNeedAsync(Need need);
        Task<IEnumerable<Need>> GetAllNeedsAsync();
		Task<IEnumerable<NeedWithVictimDetailsDto>> GetNeedWithVictimDetailsAsync(int id);
		Task<Need> UpdateNeedStatusAsync(int id, string status);

		#endregion
		#region NeedType
		Task<NeedType> CreateNeedTypeAsync(NeedType needType);
        Task<bool> DeleteNeedTypeAsync(int id);
        Task<NeedType?> GetNeedTypeByIdAsync(int id);
        Task<NeedType> UpdateNeedTypeAsync(NeedType needType);
        Task<IEnumerable<NeedType>> GetAllNeedTypesAsync();
        Task<int> GetVictimCountById(int id);
        Task<Need?> GetNeedByVictimIdAsync(int id);
        Task<int> GetVictimCountByIdFilteredByDate(int id, DateTime startDate, DateTime endDate);
#endregion


    }
}
