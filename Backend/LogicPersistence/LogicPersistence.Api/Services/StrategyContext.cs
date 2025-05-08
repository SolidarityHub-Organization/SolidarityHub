using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services{

    public class StrategyContext<T>{

        private readonly IMapStrategy<T> _strategy;
        public StrategyContext(IMapStrategy<T> strategy){
            this._strategy = strategy;
        }

        public Task<IEnumerable<T>> MostrarStrategy(){
            return _strategy.Mostrar();
        }
    }
}
