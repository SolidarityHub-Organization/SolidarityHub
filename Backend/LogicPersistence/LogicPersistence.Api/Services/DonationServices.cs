using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Models.Builders;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class DonationServices : IDonationServices {
        private readonly IDonationRepository _donationRepository;
        private readonly IVolunteerRepository _volunteerRepository;
        private readonly IPaginationService _paginationService;

        public DonationServices(IDonationRepository donationRepository, IVolunteerRepository volunteerRepository, IPaginationService paginationService) {
            _donationRepository = donationRepository;
            _volunteerRepository = volunteerRepository;
            _paginationService = paginationService;
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

            // Update the donation with victim_id set to null using the builder
            var updatedDonation = new PhysicalDonationBuilder()
                .WithId(donation.id)
                .WithItemName(donation.item_name)
                .WithDescription(donation.description)
                .WithQuantity(donation.quantity)
                .WithItemType(donation.item_type)
                .WithVolunteerId(donation.volunteer_id)
                .WithAdminId(donation.admin_id)
                .WithVictimId(null)  // Set to null to unassign
                .WithDonationDate(donation.donation_date)
                .Build();

            var result = await _donationRepository.UpdatePhysicalDonationAsync(updatedDonation);

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

        public async Task<Dictionary<string, int>> GetPhysicalDonationsCountByTypeAsync(DateTime fromDate, DateTime toDate) {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            return Enum.GetValues(typeof(PhysicalDonationType))
                .Cast<PhysicalDonationType>()
                .ToDictionary(
                    type => LogicPersistence.Api.Functionalities.EnumExtensions.GetDisplayName(type),
                    type => filteredDonations.Count(d => d.item_type == type)
                );
        }

        //por ahora solo coge donantes voluntarios, pero tmb pueden haber de otros tipos, cambiar en un futuro
        public async Task<IEnumerable<PhysicalDonationDisplayDto>> GetPhysicalDonationsByDateAsync(DateTime fromDate, DateTime toDate) {
            var donations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            var result = new List<PhysicalDonationDisplayDto>();
            foreach (var donation in filteredDonations) {
                Volunteer? volunteer = null;
                if (donation.volunteer_id.HasValue) {
                    volunteer = await _volunteerRepository.GetVolunteerByIdAsync(donation.volunteer_id.Value);
                }
                result.Add(donation.ToPhysicalDonationDisplayDto(volunteer));
            }

            return result;
        }

        public async Task<(IEnumerable<PhysicalDonation> PhysicalDonations, int TotalCount)> GetPaginatedPhysicalDonationsAsync(int pageNumber, int pageSize) {
            return await _paginationService.GetPaginatedAsync<PhysicalDonation>(pageNumber, pageSize, "physical_donation", "created_at DESC, id DESC");
        }

        public async Task<Dictionary<string, double>> GetPhysicalDonationsSumByWeekAsync(DateTime fromDate, DateTime toDate) {
            if (fromDate > toDate) {
                throw new ArgumentException("From date cannot be greater than to date.");
            }

            var donations = await _donationRepository.GetAllPhysicalDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve physical donations.");
            var result = InitializeLast8WeeksDoubleDictionary(toDate);

            var weekStartDates = result.Keys.Select(DateTime.Parse).ToHashSet();
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate && weekStartDates.Contains(GetWeekStartDate(d)));

            var groupedDonations = filteredDonations
                .GroupBy(GetWeekStartDate)
                .ToDictionary(
                    group => $"{group.Key:yyyy-MM-dd}",
                    group => group.Sum(d => d.quantity)
                );

            foreach (var kvp in groupedDonations) {
                if (result.ContainsKey(kvp.Key)) {
                    result[kvp.Key] = kvp.Value;
                }
            }

            return result;
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

        //por ahora solo coge donantes voluntarios, pero tmb pueden haber de otros tipos, cambiar en un futuro
        public async Task<IEnumerable<MonetaryDonationDisplayDto>> GetMonetaryDonationsByDateAsync(DateTime fromDate, DateTime toDate) {
            var donations = await _donationRepository.GetAllMonetaryDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve monetary donations.");
            var filteredDonations = donations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate);

            var result = new List<MonetaryDonationDisplayDto>();
            foreach (var donation in filteredDonations) {
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

        public async Task<(IEnumerable<MonetaryDonation> MonetaryDonations, int TotalCount)> GetPaginatedMonetaryDonationsAsync(int pageNumber, int pageSize) {
            return await _paginationService.GetPaginatedAsync<MonetaryDonation>(pageNumber, pageSize, "monetary_donation", "created_at DESC, id DESC");
        }

        public async Task<Dictionary<string, double>> GetMonetaryDonationsSumByWeekAsync(DateTime fromDate, DateTime toDate) {
            if (fromDate > toDate) {
                throw new ArgumentException("From date cannot be greater than to date.");
            }

            var monetaryDonations = await _donationRepository.GetAllMonetaryDonationsAsync() ?? throw new InvalidOperationException("Failed to retrieve monetary donations.");
            var result = InitializeLast8WeeksDoubleDictionary(toDate);
            var weekStartDates = result.Keys.Select(DateTime.Parse).ToHashSet();
            var filteredDonations = monetaryDonations.Where(d => d.donation_date >= fromDate && d.donation_date <= toDate && weekStartDates.Contains(GetWeekStartDate(d)));

            var groupedDonations = filteredDonations
                .GroupBy(GetWeekStartDate)
                .ToDictionary(
                    group => $"{group.Key:yyyy-MM-dd}",
                    group => group.Sum(d => d.amount)
                );

            foreach (var kvp in groupedDonations) {
                if (result.ContainsKey(kvp.Key)) {
                    result[kvp.Key] = kvp.Value;
                }
            }

            return result;
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
        #region Internal Methods

        private static DateTime GetWeekStartDate<T>(T donation) where T : Donation {
            var dayOfWeek = (int)donation.donation_date.DayOfWeek;
            var daysToSubtract = dayOfWeek == 0 ? 6 : dayOfWeek - 1;
            return donation.donation_date.Date.AddDays(-daysToSubtract);
        }

        private static Dictionary<string, double> InitializeLast8WeeksDoubleDictionary(DateTime referenceDate)
        {
            var dict = new Dictionary<string, double>();
            int daysToSubtract = (int)referenceDate.DayOfWeek == 0 ? 6 : (int)referenceDate.DayOfWeek - 1;
            DateTime weekStart = referenceDate.Date.AddDays(-daysToSubtract);

            for (int i = 7; i >= 0; i--)
            {
                var week = weekStart.AddDays(-7 * i);
                dict[week.ToString("yyyy-MM-dd")] = 0.0;
            }
            return dict;
        }

        #endregion
    }
}