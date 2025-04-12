using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LogicPersistence.Api.Models;

namespace LogicPersistence.Api.Repositories.Interfaces
{
    public interface IDonationRepository
    {
#region PhysicalDonation
        Task<PhysicalDonation> CreatePhysicalDonationAsync(PhysicalDonation donation);
        Task<PhysicalDonation> UpdatePhysicalDonationAsync(PhysicalDonation donation);
        Task<bool> DeletePhysicalDonationAsync(int id);
        Task<PhysicalDonation?> GetPhysicalDonationByIdAsync(int id);
        Task<IEnumerable<PhysicalDonation>> GetAllPhysicalDonationsAsync();
        Task<int> GetTotalAmountPhysicalDonationsAsync();
#endregion
#region MonetaryDonation
        Task<MonetaryDonation> CreateMonetaryDonationAsync(MonetaryDonation donation);
        Task<MonetaryDonation> UpdateMonetaryDonationAsync(MonetaryDonation donation);
        Task<bool> DeleteMonetaryDonationAsync(int id);
        Task<MonetaryDonation?> GetMonetaryDonationByIdAsync(int id);
        Task<IEnumerable<MonetaryDonation>> GetAllMonetaryDonationsAsync();
        Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency);
#endregion
    }
}