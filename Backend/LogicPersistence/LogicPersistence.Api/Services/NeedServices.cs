using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Mappers;

namespace LogicPersistence.Api.Services {
	public class NeedServices : INeedServices {
		private readonly INeedRepository _needRepository;

		public NeedServices(INeedRepository needRepository) {
			_needRepository = needRepository;
		}

		#region Needs
		public async Task<Need> CreateNeedAsync(NeedCreateDto needCreateDto) {
			if (needCreateDto == null) {
				throw new ArgumentNullException(nameof(needCreateDto));
			}

			var need = await _needRepository.CreateNeedAsync(needCreateDto.ToNeed());
			if (need == null) {
				throw new InvalidOperationException("Failed to create need.");
			}
			return need;
		}

		public async Task<Need> GetNeedByIdAsync(int id) {
			var need = await _needRepository.GetNeedByIdAsync(id);
			if (need == null) {
				throw new KeyNotFoundException($"Need with id {id} not found.");
			}
			return need;
		}

		public async Task<Need> GetNeedByVictimIdAsync(int id) {
			var need = await _needRepository.GetNeedByVictimIdAsync(id);
			if (need == null) {
				throw new KeyNotFoundException($"Need with id {id} not found.");
			}
			return need;
		}

		public async Task<Need> UpdateNeedAsync(int id, NeedUpdateDto needUpdateDto) {
			if (id != needUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}

			var existingNeed = await _needRepository.GetNeedByIdAsync(id);
			if (existingNeed == null) {
				throw new KeyNotFoundException($"Need with id {id} not found.");
			}

			var updatedNeed = needUpdateDto.ToNeed();
			return await _needRepository.UpdateNeedAsync(updatedNeed);
		}

		public async System.Threading.Tasks.Task DeleteNeedAsync(int id) {
			var existingNeed = await _needRepository.GetNeedByIdAsync(id);
			if (existingNeed == null) {
				throw new KeyNotFoundException($"Need with id {id} not found.");
			}

			var deletionSuccessful = await _needRepository.DeleteNeedAsync(id);
			if (!deletionSuccessful) {
				throw new InvalidOperationException($"Failed to delete need with id {id}.");
			}
		}

        public async Task<IEnumerable<Need>> GetAllNeedsAsync()
        {
            var needs = await _needRepository.GetAllNeedsAsync();
            if (needs == null)
            {
                throw new InvalidOperationException("Failed to retrieve needs.");
            }
            return needs;
        }

		public async Task<IEnumerable<NeedWithVictimDetailsDto>> GetNeedWithVictimDetailsAsync(int id) {

			var needs = await _needRepository.GetNeedWithVictimDetailsAsync(id);
			if (needs == null) {
				throw new InvalidOperationException("Failed to retrieve needs.");
			}
			return needs;

		}

		public async Task<Need> UpdateNeedStatusAsync(int id,UpdateNeedStatusDto updateNeedStatusDto) {
			var existingNeed = await _needRepository.GetNeedByIdAsync(id);
            if (existingNeed == null)
            {
                throw new KeyNotFoundException($"Need with id {id} not found.");
            }

            return await _needRepository.UpdateNeedStatusAsync(id, updateNeedStatusDto.status);
        }

		public async Task<IEnumerable<NeedsForVolunteersDto>> GetNeedsInProgressForVolunteersAsync() {
			var NeedsInProgress = await _needRepository.GetNeedsInProgressForVolunteersAsync();
			if(NeedsInProgress == null) {
				throw new InvalidOperationException("Failed to retrieve needs in progress");
			}
			return NeedsInProgress;
		}

		#endregion
		#region NeedTypes
		public async Task<NeedType> CreateNeedTypeAsync(NeedTypeCreateDto needTypeCreateDto)
        {
            if (needTypeCreateDto == null)
            {
                throw new ArgumentNullException(nameof(needTypeCreateDto));
            }

			var needType = await _needRepository.CreateNeedTypeAsync(needTypeCreateDto.ToNeedType());
			if (needType == null) {
				throw new InvalidOperationException("Failed to create need type.");
			}
			return needType;
		}

		public async Task<NeedType> GetNeedTypeByIdAsync(int id) {
			var needType = await _needRepository.GetNeedTypeByIdAsync(id);
			if (needType == null) {
				throw new KeyNotFoundException($"Need type with id {id} not found.");
			}
			return needType;
		}

		public async Task<NeedType> UpdateNeedTypeAsync(int id, NeedTypeUpdateDto needTypeUpdateDto) {
			if (id != needTypeUpdateDto.id) {
				throw new ArgumentException("Ids do not match.");
			}

			var existingNeedType = await _needRepository.GetNeedTypeByIdAsync(id);
			if (existingNeedType == null) {
				throw new KeyNotFoundException($"Need type with id {id} not found.");
			}

			var updatedNeedType = needTypeUpdateDto.ToNeedType();
			return await _needRepository.UpdateNeedTypeAsync(updatedNeedType);
		}

		public async System.Threading.Tasks.Task DeleteNeedTypeAsync(int id) {
			var existingNeedType = await _needRepository.GetNeedTypeByIdAsync(id);
			if (existingNeedType == null) {
				throw new KeyNotFoundException($"Need type with id {id} not found.");
			}

			var deletionSuccessful = await _needRepository.DeleteNeedTypeAsync(id);
			if (!deletionSuccessful) {
				throw new InvalidOperationException($"Failed to delete need type with id {id}.");
			}
		}

		public async Task<IEnumerable<NeedType>> GetAllNeedTypesAsync() {
			var needTypes = await _needRepository.GetAllNeedTypesAsync();
			if (needTypes == null) {
				throw new InvalidOperationException("Failed to retrieve need types.");
			}
			return needTypes;
		}

		public async Task<int> GetVictimCountByIdAsync(int id) {
			var needType = await _needRepository.GetNeedTypeByIdAsync(id);
			if (needType == null) {
				throw new KeyNotFoundException($"Need type with id {id} not found.");
			}

			return await _needRepository.GetVictimCountById(id);
		}

		//borrar mas tarde cuando se use el filtro en el frontend
		public async Task<IEnumerable<(string needTypeName, int count)>> GetNeedTypesWithVictimCountAsync() {
			var needTypes = await _needRepository.GetAllNeedTypesAsync();
			if (needTypes == null) {
				throw new InvalidOperationException("Failed to retrieve need types.");
			}
			var res = new List<(string needTypeName, int count)>();
			foreach (NeedType needType in needTypes) {
				var count = await _needRepository.GetVictimCountById(needType.id);
				res.Add((needType.name, count));
			}
			return res;
		}

		public async Task<Dictionary<string, int>> GetNeedTypesWithVictimCountAsync(DateTime startDate, DateTime endDate) {
			if (startDate > endDate) {
				throw new ArgumentException("Start date must be less than or equal to end date.");
			}
			var needTypes = await _needRepository.GetAllNeedTypesAsync();
			if (needTypes == null) {
				throw new InvalidOperationException("Failed to retrieve need types.");
			}
			Dictionary<string, int> res = new Dictionary<string, int>();
			foreach (NeedType needType in needTypes) {
				var count = await _needRepository.GetVictimCountByIdFilteredByDate(needType.id, startDate, endDate);
				res.Add(needType.name, count);
			}
			return res;
		}


		#endregion
	}
}
