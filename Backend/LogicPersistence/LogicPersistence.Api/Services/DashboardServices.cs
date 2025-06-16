using LogicPersistence.Api.Functionalities;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class DashboardServices : IDashboardServices {
        private readonly IVictimRepository _victimRepository;
        private readonly IVolunteerRepository _volunteerRepository;
        private readonly IDonationRepository _donationRepository;

        public DashboardServices(IVictimRepository victimRepository, IVolunteerRepository volunteerRepository, IDonationRepository donationRepository) {
            _victimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
            _donationRepository = donationRepository;
        }

        public async Task<(IEnumerable<ActivityLogDto> activityLog, int totalCount)> GetPaginatedActivityLogDataAsync(DateTime fromDate, DateTime toDate, int pageNumber, int pageSize) {
            GeneralServices.ValidateDates(fromDate, toDate);

            var recentVictims = await GetRecentVictimsAsync();
            var recentVolunteers = await GetRecentVolunteersAsync();
            var recentMonetaryDonations = await GetRecentMonetaryDonationsAsync();
            var recentPhysicalDonations = await GetRecentPhysicalDonationsAsync();

            var res = new List<ActivityLogDto>();
            res.AddRange(recentVictims);
            res.AddRange(recentVolunteers);
            res.AddRange(recentMonetaryDonations);
            res.AddRange(recentPhysicalDonations);

            var paginatedActivityLog = res.Where(x => x.date >= fromDate && x.date <= toDate)
                                        .OrderByDescending(x => x.date)
                                        .Skip((pageNumber - 1) * pageSize)
                                        .Take(pageSize)
                                        .ToList();

            return (paginatedActivityLog, res.Count(x => x.date >= fromDate && x.date <= toDate));
        }

        #region InternalMethods

        private async Task<List<ActivityLogDto>> GetRecentVictimsAsync() {
            var recentVictims = await _victimRepository.GetAllVictimsAsync();

            return recentVictims.Select(v => new ActivityLogDto {
                id = v.id,
                type = "Víctima",
                date = v.created_at,
                information = string.Format("{0} {1} se ha registrado como afectado", v.name, v.surname)
            }).ToList();
            
        }

        private async Task<List<ActivityLogDto>> GetRecentVolunteersAsync() {
            var recentVolunteers = await _volunteerRepository.GetAllVolunteersAsync();
            return recentVolunteers.Select(v => new ActivityLogDto {
                id = v.id,
                type = "Voluntario",
                date = v.created_at,
                information = string.Format("{0} {1} se ha registrado como voluntario", v.name, v.surname)
            }).ToList();
        }

        private async Task<List<ActivityLogDto>> GetRecentMonetaryDonationsAsync() {
            var recentMonetaryDonations = await _donationRepository.GetAllMonetaryDonationsAsync();
            var result = new List<ActivityLogDto>();

            foreach (var d in recentMonetaryDonations.Where(d => d.volunteer_id.HasValue && d.payment_status == PaymentStatus.Completed)) {
                var volunteer = await _volunteerRepository.GetVolunteerByIdAsync(d.volunteer_id.Value);
                result.Add(new ActivityLogDto {
                    id = d.id,
                    type = "Donación monetaria",
                    date = d.donation_date,
                    information = string.Format("{0} {1} ha donado {2} {3}.", volunteer.name, volunteer.surname, d.amount, d.currency.GetDisplayName().ToLower()),
                });
            }

            return result;
        }

        private async Task<List<ActivityLogDto>> GetRecentPhysicalDonationsAsync() {
            var recentPhysicalDonations = await _donationRepository.GetAllPhysicalDonationsAsync();
            var result = new List<ActivityLogDto>();

            foreach (var d in recentPhysicalDonations.Where(d => d.volunteer_id.HasValue)) {
                var volunteer = await _volunteerRepository.GetVolunteerByIdAsync(d.volunteer_id.Value);
                result.Add(new ActivityLogDto {
                    id = d.id,
                    type = "Donación física",
                    date = d.donation_date,
                    information = string.Format("{0} {1} ha donado {2} unidades de '{3}'.", volunteer.name, volunteer.surname, d.quantity, d.item_name),
                });
            }

            return result;
        }
#endregion
    }
}