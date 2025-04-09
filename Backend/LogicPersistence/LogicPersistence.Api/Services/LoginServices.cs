using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;

namespace LogicPersistence.Api.Services
{
    public class LoginServices : ILoginServices
    {
        private readonly IVictimRepository _VictimRepository;
        private readonly IVolunteerRepository _volunteerRepository;

        public LoginServices(IVictimRepository victimRepository, IVolunteerRepository volunteerRepository)
        {
            _VictimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
        }

        public async Task<string> LogInAsync(string email, string password)
        {
            var victim = await _VictimRepository.GetVictimByEmailAsync(email);
            if (victim != null && victim.password == password)
            {
                return "victima";
            }
			var volunteer = await _volunteerRepository.GetVolunteerByEmailAsync(email);
			if(volunteer != null && volunteer.password == password) {
				return "voluntario";
			}

            return null;
        }
    }
}
