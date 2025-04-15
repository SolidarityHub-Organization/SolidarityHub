using LogicPersistence.Api.Logic;
using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;

namespace LogicPersistence.Api.Services
{
    public class SignupServices : ISignupServices
    {
        private readonly IVictimRepository _VictimRepository;
        private readonly IVolunteerRepository _volunteerRepository;

        public SignupServices(IVictimRepository victimRepository, IVolunteerRepository volunteerRepository)
        {
            _VictimRepository = victimRepository;
            _volunteerRepository = volunteerRepository;
        }

		public async Task<IUser> CreateVolunteerAsync(Volunteer volunteer) {
			if (volunteer == null) {
				throw new ArgumentNullException(nameof(volunteer));
			}

			var res = await _volunteerRepository.CreateVolunteerAsync(volunteer);
			if (res == null) {
				throw new InvalidOperationException("Failed to create volunteer.");
			}

			return res;
		}
		public async Task<IUser> CreateVictimAsync(Victim victim) {
			if (victim == null) {
				throw new ArgumentNullException(nameof(victim));
			}

			var res = await _VictimRepository.CreateVictimAsync(victim);
			if (res == null) {
				throw new InvalidOperationException("Failed to create volunteer.");
			}

			return res;
		}
	}
}
