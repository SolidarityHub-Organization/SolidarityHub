using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services {
	public interface IVictimServices {
		Task<Victim> CreateVictimAsync(VictimCreateDto victimCreateDto);
		Task<Victim> GetVictimByIdAsync(int id);
		Task<Victim> UpdateVictimAsync(int id, VictimUpdateDto victimUpdateDto);
		System.Threading.Tasks.Task DeleteVictimAsync(int id);
		Task<IEnumerable<Victim>> GetAllVictimsAsync();
		Task<int> GetVictimsCountAsync();
		Task<IEnumerable<(string date, int count)>> GetVictimsCountByDateAsync();
	}
}
