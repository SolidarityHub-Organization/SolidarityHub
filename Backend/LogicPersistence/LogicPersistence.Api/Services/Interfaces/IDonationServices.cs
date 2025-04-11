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
#endregion
    }
}