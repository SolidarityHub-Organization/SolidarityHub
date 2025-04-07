using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;

namespace LogicPersistence.Api.Services
{
    public class AdminServices : IAdminServices
    {
        private readonly IAdminRepository _adminRepository;
        private readonly IVolunteerRepository _volunteerRepository;

        public AdminServices(IAdminRepository adminRepository, IVolunteerRepository volunteerRepository)
        {
            _adminRepository = adminRepository;
            _volunteerRepository = volunteerRepository;
        }

        public async Task<Admin> CreateAdminAsync(AdminCreateDto adminCreateDto)
        {
            if (adminCreateDto == null)
            {
                throw new ArgumentNullException(nameof(adminCreateDto));
            }

            var admin = await _adminRepository.CreateAdminAsync(adminCreateDto.ToAdmin());
            if (admin == null)
            {
                throw new InvalidOperationException("Failed to create admin.");
            }

            return admin;
        }

        public async Task<Admin> GetAdminByIdAsync(int id)
        {
            var admin = await _adminRepository.GetAdminByIdAsync(id);
            if (admin == null)
            {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }
            return admin;
        }

        public async Task<Admin> UpdateAdminAsync(int id, AdminUpdateDto adminUpdateDto)
        {
            if (id != adminUpdateDto.id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingAdmin = await _adminRepository.GetAdminByIdAsync(id);
            if (existingAdmin == null)
            {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }
            var updatedAdmin = adminUpdateDto.ToAdmin();
            await _adminRepository.UpdateAdminAsync(updatedAdmin);
            return updatedAdmin;
        }

        public async System.Threading.Tasks.Task DeleteAdminAsync(int id)
        {
            var existingAdmin = await _adminRepository.GetAdminByIdAsync(id);
            if (existingAdmin == null)
            {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }

            var deletionSuccesful = await _adminRepository.DeleteAdminAsync(id);
            if (!deletionSuccesful)
            {
                throw new InvalidOperationException($"Failed to delete admin with id {id}.");
            }
        }

        public async Task<IEnumerable<Admin>> GetAllAdminsAsync()
        {
            var admins = await _adminRepository.GetAllAdminAsync();
            if (admins == null)
            {
                throw new InvalidOperationException("Failed to retrieve admins.");
            }
            return admins;
        }

        public async Task<Admin?> GetAdminByEmailAsync(string email)
        {
            var admin = await _adminRepository.GetAdminByEmailAsync(email);
            if (admin == null)
            {
                throw new KeyNotFoundException($"Admin with email {email} not found.");
            }
            return admin;
        }

        public async Task<Admin?> GetAdminByJurisdictionAsync(string jurisdiction)
        {
            var admin = await _adminRepository.GetAdminByJurisdictionAsync(jurisdiction);
            if (admin == null)
            {
                throw new KeyNotFoundException($"Admin with jurisdiction {jurisdiction} not found.");
            }
            return admin;
        }
    }
}