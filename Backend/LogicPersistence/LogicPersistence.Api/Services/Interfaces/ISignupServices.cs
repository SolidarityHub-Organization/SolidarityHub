using LogicPersistence.Api.Logic;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface ISignupServices
    {
        Task<IUser> CreateVolunteerAsync(Volunteer user);

		Task<IUser> CreateVictimAsync(Victim user);
        
    }
}
