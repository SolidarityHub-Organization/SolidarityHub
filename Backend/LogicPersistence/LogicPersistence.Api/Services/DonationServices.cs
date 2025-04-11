using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class DonationServices : IDonationServices
    {
        private readonly IDonationRepository _donationRepository;

        public DonationServices(IDonationRepository donationRepository)
        {
            _donationRepository = donationRepository;
        }

#region PhysicalDonation
        public async Task<PhysicalDonation> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto)
        {
            if (donationCreateDto == null) {
                throw new ArgumentNullException(nameof(donationCreateDto));
            }

            var donation = await _donationRepository.CreatePhysicalDonationAsync(donationCreateDto.ToPhysicalDonation());
            if (donation == null) {
				throw new InvalidOperationException("Failed to create physical donation.");
			}
            return donation;
        }

        public async Task<PhysicalDonation> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto)
        {
            if (id != donationUpdateDto.id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingDonation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
            if (existingDonation == null)
            {
                throw new KeyNotFoundException($"Physical donation with id {id} not found.");
            }
            var updatedDonation = donationUpdateDto.ToPhysicalDonation();
            await _donationRepository.UpdatePhysicalDonationAsync(updatedDonation);
            return updatedDonation;
        }

        public async System.Threading.Tasks.Task DeletePhysicalDonationAsync(int id)
        {
            var existingDonation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
			if (existingDonation == null) {
				throw new KeyNotFoundException($"Donation with id {id} not found.");
			}

			var deletionSuccesful = await _donationRepository.DeletePhysicalDonationAsync(id);
			if (!deletionSuccesful) {
				throw new InvalidOperationException($"Failed to delete physical donation with id {id}.");
			}
        }

        public async Task<PhysicalDonation> GetPhysicalDonationByIdAsync(int id) {
			var donation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
			if (donation == null) {
				throw new KeyNotFoundException($"Donation with id {id} not found.");
			}
			return donation;
		}

        public async Task<IEnumerable<PhysicalDonation>> GetAllPhysicalDonationsAsync()
        {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync();
			if (donations == null) {
				throw new InvalidOperationException("Failed to retrieve donations.");
			}
			return donations;
        }
#endregion
    }
}