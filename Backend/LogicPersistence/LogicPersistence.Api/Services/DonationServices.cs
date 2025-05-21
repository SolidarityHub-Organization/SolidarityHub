using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class DonationServices : IDonationServices {
        private readonly IDonationRepository _donationRepository;
        private readonly IVolunteerRepository _volunteerRepository;

        public DonationServices(IDonationRepository donationRepository, IVolunteerRepository volunteerRepository) {
            _donationRepository = donationRepository;
            _volunteerRepository = volunteerRepository;
        }

        #region PhysicalDonation
        public async Task<PhysicalDonationDisplayDto> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto) {
            if (donationCreateDto == null) {
                throw new ArgumentNullException(nameof(donationCreateDto));
            }

            var donation = await _donationRepository.CreatePhysicalDonationAsync(donationCreateDto.ToPhysicalDonation());
            if (donation == null) {
                throw new InvalidOperationException("Failed to create physical donation.");
            }

            Volunteer? volunteer = null;
            if (donation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
            }

            return donation.ToPhysicalDonationDisplayDto(volunteer);
        }

        public async Task<PhysicalDonationDisplayDto> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto) {
            if (id != donationUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingDonation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Physical donation with id {id} not found.");
            }
            var updatedDonation = donationUpdateDto.ToPhysicalDonation();
            await _donationRepository.UpdatePhysicalDonationAsync(updatedDonation);

            Volunteer? volunteer = null;
            if (updatedDonation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(updatedDonation.volunteer_id.Value);
            }

            return updatedDonation.ToPhysicalDonationDisplayDto(volunteer);
        }

        public async System.Threading.Tasks.Task DeletePhysicalDonationAsync(int id) {
            var existingDonation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }

            var deletionSuccesful = await _donationRepository.DeletePhysicalDonationAsync(id);
            if (!deletionSuccesful) {
                throw new InvalidOperationException($"Failed to delete physical donation with id {id}.");
            }
        }

        public async Task<PhysicalDonationDisplayDto> GetPhysicalDonationByIdAsync(int id) {
            var donation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
            if (donation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }

            Volunteer? volunteer = null;
            if (donation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
            }

            return donation.ToPhysicalDonationDisplayDto(volunteer);
        }

        public async Task<IEnumerable<PhysicalDonationDisplayDto>> GetAllPhysicalDonationsAsync() {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync();
            if (donations == null) {
                throw new InvalidOperationException("Failed to retrieve donations.");
            }

            var result = new List<PhysicalDonationDisplayDto>();
            foreach (var donation in donations) {
                Volunteer? volunteer = null;
                if (donation.volunteer_id.HasValue) {
                    volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
                }
                result.Add(donation.ToPhysicalDonationDisplayDto(volunteer));
            }

            return result;
        }

        public async Task<int> GetTotalAmountPhysicalDonationsAsync(DateTime fromDate, DateTime toDate) {
            if (fromDate > toDate) {
                throw new ArgumentException("From date cannot be greater than to date.");
            }
            return await _donationRepository.GetTotalAmountPhysicalDonationsAsync(fromDate, toDate);
        }

        public async Task<PhysicalDonationDisplayDto> UnassignPhysicalDonationAsync(int id) {
            var donation = await _donationRepository.GetPhysicalDonationByIdAsync(id);
            if (donation == null) {
                throw new KeyNotFoundException($"Physical donation with id {id} not found");
            }

            // Update the donation with victim_id set to null
            donation.victim_id = null;
            var result = await _donationRepository.UpdatePhysicalDonationAsync(donation);

            if (result == null) {
                throw new InvalidOperationException("Failed to unassign physical donation");
            }

            Volunteer? volunteer = null;
            if (result.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(result.volunteer_id.Value);
            }

            return result.ToPhysicalDonationDisplayDto(volunteer);
        }

        public async Task<Dictionary<string, int>> GetPhysicalDonationsTotalAmountByTypeAsync(DateTime fromDate, DateTime toDate) {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            return Enum.GetValues(typeof(PhysicalDonationType))
                .Cast<PhysicalDonationType>()
                .ToDictionary(
                    type => LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(type),
                    type => filteredDonations.Where(d => d.item_type == type).Sum(d => d.quantity)
                );
        }

        public async Task<Dictionary<string, int>> GetPhysicalDonationsCountByTypeAsync(DateTime fromDate, DateTime toDate) 
        {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            return Enum.GetValues(typeof(PhysicalDonationType))
                .Cast<PhysicalDonationType>()
                .ToDictionary(
                    type => LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(type),
                    type => filteredDonations.Count(d => d.item_type == type)
                );
        }
        #endregion
        #region MonetaryDonation

        public async Task<MonetaryDonationDisplayDto> CreateMonetaryDonationAsync(MonetaryDonationCreateDto donationCreateDto) {
            if (donationCreateDto == null) {
                throw new ArgumentNullException(nameof(donationCreateDto));
            }
            var donation = await _donationRepository.CreateMonetaryDonationAsync(donationCreateDto.ToMonetaryDonation());
            if (donation == null) {
                throw new InvalidOperationException("Failed to create monetary donation.");
            }

            Volunteer? volunteer = null;
            if (donation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
            }

            return donation.ToMonetaryDonationDisplayDto(volunteer);
        }

        public async Task<MonetaryDonationDisplayDto> UpdateMonetaryDonationAsync(int id, MonetaryDonationUpdateDto donationUpdateDto) {
            if (id != donationUpdateDto.id) {
                throw new ArgumentException("Ids do not match.");
            }
            var existingDonation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Monetary donation with id {id} not found.");
            }
            var updatedDonation = donationUpdateDto.ToMonetaryDonation();
            await _donationRepository.UpdateMonetaryDonationAsync(updatedDonation);

            Volunteer? volunteer = null;
            if (updatedDonation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(updatedDonation.volunteer_id.Value);
            }

            return updatedDonation.ToMonetaryDonationDisplayDto(volunteer);
        }

        public async System.Threading.Tasks.Task DeleteMonetaryDonationAsync(int id) {
            var existingDonation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (existingDonation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }
            var deletionSuccesful = await _donationRepository.DeleteMonetaryDonationAsync(id);
            if (!deletionSuccesful) {
                throw new InvalidOperationException($"Failed to delete monetary donation with id {id}.");
            }
        }

        public async Task<MonetaryDonationDisplayDto> GetMonetaryDonationByIdAsync(int id) {
            var donation = await _donationRepository.GetMonetaryDonationByIdAsync(id);
            if (donation == null) {
                throw new KeyNotFoundException($"Donation with id {id} not found.");
            }

            Volunteer? volunteer = null;
            if (donation.volunteer_id.HasValue) {
                volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
            }

            return donation.ToMonetaryDonationDisplayDto(volunteer);
        }

        public async Task<IEnumerable<MonetaryDonationDisplayDto>> GetAllMonetaryDonationsAsync() {
            var donations = await _donationRepository.GetAllMonetaryDonationsAsync();
            if (donations == null) {
                throw new InvalidOperationException("Failed to retrieve donations.");
            }

            var result = new List<MonetaryDonationDisplayDto>();
            foreach (var donation in donations) {
                Volunteer? volunteer = null;
                if (donation.volunteer_id.HasValue) {
                    volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
                }
                result.Add(donation.ToMonetaryDonationDisplayDto(volunteer));
            }

            return result;
        }

        //por ahora solo acepta EUR y USD
        public async Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency, DateTime fromDate, DateTime toDate) {
            var totalEuro = await _donationRepository.GetTotalMonetaryAmountByCurrencyAsync(Currency.EUR, fromDate, toDate);
            var totalDollar = await _donationRepository.GetTotalMonetaryAmountByCurrencyAsync(Currency.USD, fromDate, toDate);
            if (totalEuro < 0 || totalDollar < 0) {
                throw new InvalidOperationException("Failed to retrieve total amount of donations.");
            }

            switch (currency) {
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
        #region Other methods
        public async Task<int> GetTotalAmountDonorsAsync(DateTime fromDate, DateTime toDate) {
            var monetaryDonations = await _donationRepository.GetAllMonetaryDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve monetary donations.");
            var physicalDonations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");

            var filteredMonetaryDonations = monetaryDonations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);
            var filteredPhysicalDonations = physicalDonations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            var uniqueDonors = new HashSet<(string type, int id)>();

            foreach (var donation in filteredMonetaryDonations) {
                if (donation.volunteer_id.HasValue) { uniqueDonors.Add(("volunteer", donation.volunteer_id.Value)); }
                if (donation.admin_id.HasValue) { uniqueDonors.Add(("admin", donation.admin_id.Value)); }
                if (donation.victim_id.HasValue) { uniqueDonors.Add(("victim", donation.victim_id.Value)); }
            }

            foreach (var donation in filteredPhysicalDonations) {
                if (donation.volunteer_id.HasValue) { uniqueDonors.Add(("volunteer", donation.volunteer_id.Value)); }
                if (donation.admin_id.HasValue) { uniqueDonors.Add(("admin", donation.admin_id.Value)); }
                if (donation.victim_id.HasValue) { uniqueDonors.Add(("victim", donation.victim_id.Value)); }
            }

            return uniqueDonors.Count;
        }
        #endregion
    }
}