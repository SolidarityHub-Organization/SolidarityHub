
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services{
    public interface IMapStrategy<T>{
       Task<IEnumerable<T>> Mostrar();
    }
}
