using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Services
{
    public interface IPersonServices
    {
        Task<Person> CreatePerson(PersonCreateDto personCreateDto);
        Task<Person> GetPersonByIdAsync(int id);
        Task<Person> UpdatePersonAsync(int id, PersonUpdateDto personUpdateDto);
        Task DeletePersonAsync(int id);
        Task<IEnumerable<Person>> GetPeopleAsync();
    }
}