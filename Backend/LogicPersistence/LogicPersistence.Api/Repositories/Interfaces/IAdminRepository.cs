namespace LogicPersistence.Api.Repositories;

using LogicPersistence.Api.Models;

public interface IAdminRepository
{
    Task<Admin> CreateAdminAsync(Admin admin);
    Task<Admin> UpdateAdminAsync(Admin admin);
    Task<bool> DeleteAdminAsync(int id);
    Task<IEnumerable<Admin>> GetAllAdminAsync();
    Task<Admin?> GetAdminByIdAsync(int id);
    Task<Admin?> GetAdminByEmailAsync(string email);
    Task<Admin?> GetAdminByJurisdictionAsync(string jurisdiction);
}