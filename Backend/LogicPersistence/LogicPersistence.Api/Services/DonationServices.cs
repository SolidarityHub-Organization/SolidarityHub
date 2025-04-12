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

        public async Task<int> GetTotalAmountPhysicalDonationsAsync()
        {
            var totalAmount = await _donationRepository.GetTotalAmountPhysicalDonationsAsync();
            if (totalAmount < 0) {
                throw new InvalidOperationException("Failed to retrieve total amount of donations.");
            }
            return totalAmount;
        }
#endregion
#region MonetaryDonation

        public async Task<MonetaryDonation> CreateMonetaryDonationAsync(MonetaryDonationCreateDto donationCreateDto)
        {
            if (donationCreateDto == null) {
                throw new ArgumentNullException(nameof(donationCreateDto));
            }
            var donation = await _donationRepository.CreateMonetaryDonationAsync(donationCreateDto.ToMonetaryDonation());
            if (donation == null) {
                throw new InvalidOperationException("Failed to create monetary donation.");
            }
            return donation;
        }

        public async Task<MonetaryDonation> UpdateMonetaryDonationAsync(int id, MonetaryDonationUpdateDto donationUpdateDto)
        {
            if (id != donationUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingDonation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Monetary donation with id {id} not found.");
            }
            var updatedDonation = donationUpdateDto.ToMonetaryDonation();
            await _donationRepository.UpdateMonetaryDonationAsync(updatedDonation);
            return updatedDonation;
        }

        public async System.Threading.Tasks.Task DeleteMonetaryDonationAsync(int id)
        {
            var existingDonation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }
            var deletionSuccesful = await _donationRepository.DeleteMonetaryDonationAsync(id);
            if (!deletionSuccesful) {
                throw new InvalidOperationException($"Failed to delete monetary donation with id {id}.");
            }
        }

        public async Task<MonetaryDonation> GetMonetaryDonationByIdAsync(int id) {
            var donation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (donation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }
            return donation;
        }

        public async Task<IEnumerable<MonetaryDonation>> GetAllMonetaryDonationsAsync() {
            var donations = await _donationRepository.GetAllMonetaryDonationsAsync();
            if (donations == null) {
                throw new InvalidOperationException("Failed to retrieve donations.");
            }
            return donations;
        }

        public async Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency) {
            var totalEuro = await _donationRepository.GetTotalMonetaryAmountByCurrencyAsync(Currency.EUR);
            var totalDollar = await _donationRepository.GetTotalMonetaryAmountByCurrencyAsync(Currency.USD);
            if (totalEuro < 0 || totalDollar < 0) {
                throw new InvalidOperationException("Failed to retrieve total amount of donations.");
            }

            switch (currency)
            {
                case Currency.EUR:
                     totalDollar *= 0.88;
                     break;
                case Currency.USD:
                     totalEuro *= 1.14;
                     break;
                default:
                    throw new ArgumentException("Invalid currency type.");
            }

            return totalEuro + totalDollar;
        }


#endregion
    }
}