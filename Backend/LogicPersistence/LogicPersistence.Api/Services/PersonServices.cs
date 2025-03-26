using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;


// The services are the classes that contain the business logic of the application. They are responsible for processing the data and performing the necessary operations to fulfill the requests from the client passed from the controllers.
// It must be attached to the repository to be able to perform the necessary operations on the database.

namespace LogicPersistence.Api.Services
{
    public class PersonServices : IPersonServices
    {
        private readonly IPersonRepository _personRepository;

        public PersonServices(IPersonRepository personRepository)
        {
            _personRepository = personRepository;
        }


        public async Task<Person> CreatePerson(PersonCreateDto personCreateDto)
        {
            if (personCreateDto == null)
            {
                throw new ArgumentNullException(nameof(personCreateDto));
            }
            
            var person = await _personRepository.CreatePersonAsync(personCreateDto.ToPerson());
            if (person == null)
            {
                throw new InvalidOperationException("Failed to create person.");
            }

            return person;
        }

        public async Task<Person> GetPersonByIdAsync(int id)
        {
            var person = await _personRepository.GetPersonByIdAsync(id);
            if (person == null)
            {
                throw new KeyNotFoundException($"Person with id {id} not found.");
            }
            return person;
        }

        public async Task<Person> UpdatePersonAsync(int id, PersonUpdateDto personUpdateDto)
        {
            if (id != personUpdateDto.Id)
            {
                throw new ArgumentException("Ids do not match.");
            }
            var existingPerson = await _personRepository.GetPersonByIdAsync(id);
            if (existingPerson == null)
            {
                throw new KeyNotFoundException($"Person with id {id} not found.");
            }
            var updatedPerson = personUpdateDto.ToPerson();
            await _personRepository.UpdatePersonAsync(updatedPerson);
            return updatedPerson;
        }

        public async Task DeletePersonAsync(int id)
        {
            var existingPerson = await _personRepository.GetPersonByIdAsync(id);
            if (existingPerson == null)
            {
                throw new KeyNotFoundException($"Person with id {id} not found.");
            }
            
            await _personRepository.DeletePersonAsync(id);
        }

        public async Task<IEnumerable<Person>> GetPeopleAsync()
        {
            var people = await _personRepository.GetAllPersonAsync();
            if (people == null)
            {
                throw new InvalidOperationException("Failed to retrieve people.");
            }
            return people;
        }
    }
}