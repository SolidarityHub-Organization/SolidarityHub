using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using Microsoft.AspNetCore.Http.HttpResults;


namespace LogicPersistence.Api.Services {
	public class LoginServices : ILoginServices {
		private readonly IVictimRepository _VictimRepository;
		private readonly IVolunteerRepository _volunteerRepository;

		public LoginServices(IVictimRepository victimRepository, IVolunteerRepository volunteerRepository) {
			_VictimRepository = victimRepository;
			_volunteerRepository = volunteerRepository;
		}

		public async Task<string> LogInAsync(string email, string password) {
			var victim = await _VictimRepository.GetVictimByEmailAsync(email);
			if (victim != null && victim.password == password) {
				return System.Text.Json.JsonSerializer.Serialize(new { role = "victima", id = victim.id, name = victim.name });
			}
			var volunteer = await _volunteerRepository.GetVolunteerByEmailAsync(email);
			if (volunteer != null && volunteer.password == password) {
				return System.Text.Json.JsonSerializer.Serialize(new { role = "voluntario", id = volunteer.id, name = volunteer.name });
			}
			if (victim != null || volunteer != null) // Check if the email exists in either table
			{
				return System.Text.Json.JsonSerializer.Serialize(new { role = "password incorrect" });
			}
			{
				return System.Text.Json.JsonSerializer.Serialize(new { role = "exists" });
			}
		}
	}
}
