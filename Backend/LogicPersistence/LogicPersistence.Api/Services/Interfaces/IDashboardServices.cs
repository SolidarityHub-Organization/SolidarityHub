using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IDashboardServices
    {
        Task<(IEnumerable<ActivityLogDto> activityLog, int totalCount)> GetPaginatedActivityLogDataAsync(DateTime fromDate, DateTime toDate, int pageNumber, int pageSize);
    }
}