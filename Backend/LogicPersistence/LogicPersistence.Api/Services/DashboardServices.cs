using LogicPersistence.Api.Functionalities;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Services
{
    public class DashboardServices : IDashboardServices
    {
        private readonly IVictimRepository _victimRepository;
        private readonly IVolunteerRepository _volunteerRepository;
        private readonly IDonationRepository _donationRepository;

        public DashboardServices(IVictimRepository victimRepository, IVolunteerRepository volunteerRepository, IDonationRepository donationRepository)
        {
            _victimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
            _donationRepository = donationRepository;
        }

        public async Task<IEnumerable<ActivityLogDto>> GetActivityLogDataAsync(DateTime fromDate, DateTime toDate)
        {
            if (fromDate > toDate)
            {
                throw new ArgumentException("From date cannot be greater than to date.");
            }
            var recentVictims = await GetRecentVictimsAsync();
            var recentVolunteers = await GetRecentVolunteersAsync();
            var recentMonetaryDonations = await GetRecentMonetaryDonationsAsync();
            
            var res = new List<ActivityLogDto>();
            res.AddRange(recentVictims);
            res.AddRange(recentVolunteers);
            res.AddRange(recentMonetaryDonations);

            return res.Where(x => x.date >= fromDate && x.date <= toDate).OrderByDescending(x => x.date).Take(10).ToList();
        }

#region InternalMethods

        private async Task<List<ActivityLogDto>> GetRecentVictimsAsync()
        {
            var recentVictims = await _victimRepository.GetAllVictimsAsync();
            return recentVictims.Select(v => new ActivityLogDto
            {
                id = v.id,
                name = v.name + " " + v.surname,
                type = "Víctima",
                date = v.created_at
            }).ToList();
        }

        private async Task<List<ActivityLogDto>> GetRecentVolunteersAsync()
        {
            var recentVolunteers = await _volunteerRepository.GetAllVolunteersAsync();
            return recentVolunteers.Select(v => new ActivityLogDto
            {
                id = v.id,
                name = v.name + " " + v.surname,
                type = "Voluntario",
                date = v.created_at
            }).ToList();
        }

        private async Task<List<ActivityLogDto>> GetRecentMonetaryDonationsAsync()
        {
            var recentMonetaryDonations = await _donationRepository.GetAllMonetaryDonationsAsync();
            var result = new List<ActivityLogDto>();

            foreach (var d in recentMonetaryDonations.Where(d => d.volunteer_id.HasValue && d.payment_status == PaymentStatus.Completed))
            {
                var volunteer = await _volunteerRepository.GetVolunteerByIdAsync(d.volunteer_id.Value);
                result.Add(new ActivityLogDto
                {
                    id = d.id,
                    name = volunteer.name + " " + volunteer.surname,
                    amount = d.amount,
                    type = "Donación monetaria",
                    date = d.donation_date,
                    currency = d.currency.GetDisplayName()
                });
            }

            return result;
        }
#endregion
    }
}