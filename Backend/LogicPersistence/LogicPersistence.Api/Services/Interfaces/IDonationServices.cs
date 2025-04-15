using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services 
{
    public interface IDonationServices
    {
#region PhysicalDonation
        Task<PhysicalDonation> CreatePhysicalDonationAsync(PhysicalDonationCreateDto donationCreateDto);        
        Task<PhysicalDonation> UpdatePhysicalDonationAsync(int id, PhysicalDonationUpdateDto donationUpdateDto);       
        System.Threading.Tasks.Task DeletePhysicalDonationAsync(int id);
        Task<PhysicalDonation> GetPhysicalDonationByIdAsync(int id);
        Task<IEnumerable<PhysicalDonation>> GetAllPhysicalDonationsAsync();
        Task<int> GetTotalAmountPhysicalDonationsAsync();
#endregion
#region MonetaryDonation
        Task<MonetaryDonation> CreateMonetaryDonationAsync(MonetaryDonationCreateDto donationCreateDto);        
        Task<MonetaryDonation> UpdateMonetaryDonationAsync(int id, MonetaryDonationUpdateDto donationUpdateDto);       
        System.Threading.Tasks.Task DeleteMonetaryDonationAsync(int id);
        Task<MonetaryDonation> GetMonetaryDonationByIdAsync(int id);
        Task<IEnumerable<MonetaryDonation>> GetAllMonetaryDonationsAsync();
        Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency);
#endregion
    }
}