using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Mappers;

namespace LogicPersistence.Api.Services
{
    public class VolunteerServices : IVolunteerServices
    {
        private readonly IVolunteerRepository _volunteerRepository;

        public VolunteerServices(IVolunteerRepository volunteerRepository)
        {
            _volunteerRepository = volunteerRepository;
        }

        public async Task<Volunteer> CreateVolunteerAsync(VolunteerCreateDto volunteerCreateDto)
        {
            if (volunteerCreateDto == null)
            {
                throw new ArgumentNullException(nameof(volunteerCreateDto));
            }

            var volunteer = await _volunteerRepository.CreateVolunteerAsync(volunteerCreateDto.ToVolunteer());
            if (volunteer == null)
            {
                throw new InvalidOperationException("Failed to create volunteer.");
            }

            return volunteer;
        }

        public async Task<Volunteer> GetVolunteerByIdAsync(int id)
        {
            var volunteer = await _volunteerRepository.GetVolunteerByIdAsync(id);
            if (volunteer == null)
            {
                throw new KeyNotFoundException($"Volunteer with id {id} not found.");
            }
            return volunteer;
        }

        public async Task<VolunteerDisplayDto> GetVolunteerDisplayByIdAsync(int id)
        {
            var volunteer = await GetVolunteerByIdAsync(id);
            // convert Volunteer to VolunteerDisplayDto to remove sensitive data
            var volunteerDto = volunteer.ToVolunteerDisplayDto();
            return volunteerDto;
        }

        public async Task<Volunteer> UpdateVolunteerAsync(int id, VolunteerUpdateDto volunteerUpdateDto)
        {
            if (id != volunteerUpdateDto.id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingVolunteer = await _volunteerRepository.GetVolunteerByIdAsync(id);
            if (existingVolunteer == null)
            {
                throw new KeyNotFoundException($"Volunteer with id {id} not found.");
            }
            var updatedVolunteer = volunteerUpdateDto.ToVolunteer();
            await _volunteerRepository.UpdateVolunteerAsync(updatedVolunteer);
            return updatedVolunteer;
        }

        public async System.Threading.Tasks.Task DeleteVolunteerAsync(int id)
        {
            var existingVolunteer = await _volunteerRepository.GetVolunteerByIdAsync(id);
            if (existingVolunteer == null)
            {
                throw new KeyNotFoundException($"Volunteer with id {id} not found.");
            }

            var deletionSuccesful = await _volunteerRepository.DeleteVolunteerAsync(id);
            if (!deletionSuccesful)
            {
                throw new InvalidOperationException($"Failed to delete volunteer with id {id}.");
            }
        }

        public async Task<IEnumerable<Volunteer>> GetAllVolunteersAsync()
        {
            var volunteers = await _volunteerRepository.GetAllVolunteersAsync();
            if (volunteers == null)
            {
                throw new InvalidOperationException("Failed to retrieve volunteers.");
            }
            return volunteers;
        }

        public async Task<IEnumerable<VolunteerWithDetailsDisplayDto>> GetAllVolunteersWithDetailsAsync()
        {
            var volunteers = await _volunteerRepository.GetAllVolunteersWithDetailsAsync();
            if (volunteers == null)
            {
                throw new InvalidOperationException($"Failed to retrieve volunteers.");
            }
            return volunteers;
        }

        public async Task<Volunteer?> GetVolunteerByEmailAsync(string email)
        {
            if (string.IsNullOrEmpty(email))
            {
                throw new ArgumentNullException(nameof(email));
            }
            var volunteer = await _volunteerRepository.GetVolunteerByEmailAsync(email);
            if (volunteer == null)
            {
                throw new KeyNotFoundException($"Volunteer with email {email} not found.");
            }
            return volunteer;
        }

        public async Task<int> GetVolunteersCountAsync(DateTime fromDate, DateTime toDate)
        {
            if (fromDate > toDate)
            {
                throw new ArgumentException("From date cannot be greater than to date.");
            }
            var volunteers = await _volunteerRepository.GetAllVolunteersAsync();
            if (volunteers == null)
            {
                throw new InvalidOperationException("Failed to retrieve volunteers.");
            }
            volunteers = volunteers.Where(v => v.created_at >= fromDate && v.created_at <= toDate).ToList();
            return volunteers.Count();
        }
    }
}
