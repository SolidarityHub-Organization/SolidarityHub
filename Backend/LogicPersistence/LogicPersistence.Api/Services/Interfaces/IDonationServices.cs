using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IDonationServices {
        #region PhysicalDonation
        Task<PhysicalDonationDisplayDto> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto);
        Task<PhysicalDonationDisplayDto> GetPhysicalDonationByIdAsync(int id);
        Task<PhysicalDonationDisplayDto> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto);
        System.Threading.Tasks.Task DeletePhysicalDonationAsync(int id);
        Task<IEnumerable<PhysicalDonationDisplayDto>> GetAllPhysicalDonationsAsync();
        Task<int> GetTotalAmountPhysicalDonationsAsync(DateTime fromDate, DateTime toDate);
        Task<PhysicalDonationDisplayDto> UnassignPhysicalDonationAsync(int id);
        Task<Dictionary<string, int>> GetPhysicalDonationsTotalAmountByTypeAsync(DateTime fromDate, DateTime toDate);
        Task<Dictionary<string, int>> GetPhysicalDonationsCountByTypeAsync(DateTime fromDate, DateTime toDate);
        Task<IEnumerable<PhysicalDonationDisplayDto>> GetPhysicalDonationsByDateAsync(DateTime fromDate, DateTime toDate);
		Task<(IEnumerable<PhysicalDonation> PhysicalDonations, int TotalCount)> GetPaginatedPhysicalDonationsAsync(int pageNumber, int pageSize);

        #endregion

        #region MonetaryDonation
        Task<MonetaryDonationDisplayDto> CreateMonetaryDonationAsync(MonetaryDonationCreateDto donationCreateDto);
        Task<MonetaryDonationDisplayDto> GetMonetaryDonationByIdAsync(int id);
        Task<MonetaryDonationDisplayDto> UpdateMonetaryDonationAsync(int id, MonetaryDonationUpdateDto donationUpdateDto);
        System.Threading.Tasks.Task DeleteMonetaryDonationAsync(int id);
        Task<IEnumerable<MonetaryDonationDisplayDto>> GetAllMonetaryDonationsAsync();
        Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency, DateTime fromDate, DateTime toDate);
        Task<IEnumerable<MonetaryDonationDisplayDto>> GetMonetaryDonationsByDateAsync(DateTime fromDate, DateTime toDate);
        Task<(IEnumerable<MonetaryDonation> MonetaryDonations, int TotalCount)> GetPaginatedMonetaryDonationsAsync(int pageNumber, int pageSize);

        #endregion

        #region Other methods
        Task<int> GetTotalAmountDonorsAsync(DateTime fromDate, DateTime toDate);
        #endregion
    }
}