using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IDashboardServices
    {
        Task<IEnumerable<RecentActivityDto>> GetRecentActivityAsync();
    }
}