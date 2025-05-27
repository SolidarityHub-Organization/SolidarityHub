using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Services.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class AdminServices : IAdminServices {
        private readonly IAdminRepository _adminRepository;
        private readonly IVolunteerRepository _volunteerRepository;
        private readonly IPaginationService _paginationService;

        public AdminServices(IAdminRepository adminRepository, IVolunteerRepository volunteerRepository, IPaginationService paginationService) {
            _adminRepository = adminRepository;
            _volunteerRepository = volunteerRepository;
            _paginationService = paginationService;
        }

        public async Task<Admin> CreateAdminAsync(AdminCreateDto adminCreateDto) {
            if (adminCreateDto == null) {
                throw new ArgumentNullException(nameof(adminCreateDto));
            }

            var admin = adminCreateDto.ToAdmin();
            if (await _adminRepository.EmailExistsAsync(admin.email)) {
                throw new Exception("Email already in use.");
            }

            admin = await _adminRepository.CreateAdminAsync(admin);
            if (admin == null) {
                throw new InvalidOperationException("Failed to create admin.");
            }

            return admin;
        }

        public async Task<Admin> GetAdminByIdAsync(int id) {
            var admin = await _adminRepository.GetAdminByIdAsync(id);
            if (admin == null) {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }
            return admin;
        }

        public async Task<Admin> UpdateAdminAsync(int id, AdminUpdateDto adminUpdateDto) {
            if (id != adminUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingAdmin = await _adminRepository.GetAdminByIdAsync(id);
            if (existingAdmin == null) {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }

            var admin = adminUpdateDto.ToAdmin();
            if (await _adminRepository.EmailExistsAsync(admin.email)) {
                throw new Exception("Email already in use.");
            }
            await _adminRepository.UpdateAdminAsync(admin);
            return admin;
        }

        public async System.Threading.Tasks.Task DeleteAdminAsync(int id) {
            var existingAdmin = await _adminRepository.GetAdminByIdAsync(id);
            if (existingAdmin == null) {
                throw new KeyNotFoundException($"Admin with id {id} not found.");
            }

            var deletionSuccesful = await _adminRepository.DeleteAdminAsync(id);
            if (!deletionSuccesful) {
                throw new InvalidOperationException($"Failed to delete admin with id {id}.");
            }
        }

        public async Task<IEnumerable<Admin>> GetAllAdminsAsync() {
            var admins = await _adminRepository.GetAllAdminAsync();
            if (admins == null) {
                throw new InvalidOperationException("Failed to retrieve admins.");
            }
            return admins;
        }

        public async Task<Admin?> GetAdminByEmailAsync(string email) {
            var admin = await _adminRepository.GetAdminByEmailAsync(email);
            if (admin == null) {
                throw new KeyNotFoundException($"Admin with email {email} not found.");
            }
            return admin;
        }

        public async Task<Admin?> GetAdminByJurisdictionAsync(string jurisdiction) {
            var admin = await _adminRepository.GetAdminByJurisdictionAsync(jurisdiction);
            if (admin == null) {
                throw new KeyNotFoundException($"Admin with jurisdiction {jurisdiction} not found.");
            }
            return admin;
        }

        public async Task<bool> LogInAdminAsync(string email, string password) {
            var admin = await _adminRepository.GetAdminByEmailAsync(email);
            if (admin != null && admin.password == password) {
                return true;
            }
            return false;
        }
        
        public async Task<(IEnumerable<Admin> Admins, int TotalCount)> GetPaginatedAdminsAsync(int pageNumber, int pageSize) {
            return await _paginationService.GetPaginatedAsync<Admin>(pageNumber, pageSize, "admin", "created_at DESC, id DESC");
        }
    }
}