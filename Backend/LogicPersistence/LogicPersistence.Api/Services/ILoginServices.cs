using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface ILoginServices
    {
        Task<string> LogInAsync(string email, string password);
        
    }
}
