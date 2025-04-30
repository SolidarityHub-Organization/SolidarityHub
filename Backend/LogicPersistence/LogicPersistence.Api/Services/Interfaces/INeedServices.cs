using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface INeedServices
    {
#region Need
    Task<Need> CreateNeedAsync(NeedCreateDto needCreateDto);
    Task<Need> GetNeedByIdAsync(int id);
    Task<Need> UpdateNeedAsync(int id, NeedUpdateDto needUpdateDto);
    System.Threading.Tasks.Task DeleteNeedAsync(int id);
    Task<IEnumerable<Need>> GetAllNeedsAsync();
#endregion

#region NeedType
    Task<NeedType> CreateNeedTypeAsync(NeedTypeCreateDto needTypeCreateDto);
    Task<NeedType> GetNeedTypeByIdAsync(int id);
    Task<NeedType> UpdateNeedTypeAsync(int id, NeedTypeUpdateDto needTypeUpdateDto);
    System.Threading.Tasks.Task DeleteNeedTypeAsync(int id);
    Task<IEnumerable<NeedType>> GetAllNeedTypesAsync();
    Task<int> GetVictimCountByIdAsync(int id);
    Task<IEnumerable<(string needTypeName, int count)>> GetNeedTypesWithVictimCountAsync();
    Task<Dictionary<string, int>> GetNeedTypesWithVictimCountAsync(DateTime startDate, DateTime endDate);
#endregion
    }
    
}