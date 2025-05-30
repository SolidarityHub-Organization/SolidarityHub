
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services {
    public interface IMapStrategy<AffectedZoneWithPointsDTO> {
        Task<IEnumerable<AffectedZoneWithPointsDTO>> Mostrar();
    }
}
