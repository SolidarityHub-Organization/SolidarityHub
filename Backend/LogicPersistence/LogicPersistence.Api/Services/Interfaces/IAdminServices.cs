using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IAdminServices {
        Task<Admin> CreateAdminAsync(AdminCreateDto adminCreateDto);
        Task<Admin> GetAdminByIdAsync(int id);
        Task<Admin> UpdateAdminAsync(int id, AdminUpdateDto adminUpdateDto);
        System.Threading.Tasks.Task DeleteAdminAsync(int id);
        Task<IEnumerable<Admin>> GetAllAdminsAsync();
        Task<Admin?> GetAdminByEmailAsync(string email);
        Task<Admin?> GetAdminByJurisdictionAsync(string jurisdiction);
        Task<bool> LogInAdminAsync(string email, string password);
        Task<(IEnumerable<Admin> Admins, int TotalCount)> GetPaginatedAdminsAsync(int pageNumber, int pageSize);
    }
}