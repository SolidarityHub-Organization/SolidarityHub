
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services{

    public class Map {

        private IMapStrategy<AffectedZoneWithPointsDTO> _strategy;
        public Map(IMapStrategy<AffectedZoneWithPointsDTO> strategy) {
            this._strategy = strategy;
        }

        public Map() {
            this._strategy = null!;
        }

        public void setStrategy(IMapStrategy<AffectedZoneWithPointsDTO> imapStrategy) {
            this._strategy = imapStrategy;
        }

        public Task<IEnumerable<AffectedZoneWithPointsDTO>> MostrarStrategy() {
                return _strategy.Mostrar();  
        }
    }
}
