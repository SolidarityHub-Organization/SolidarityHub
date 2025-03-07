using DapperPostgresDemo.Api.Mappers;
using DapperPostgresDemo.Api.Models.DTOs;
using DapperPostgresDemo.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace DapperPostgresDemo.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PeopleController : ControllerBase
    {
        private readonly IPersonRepository _personRepository;

        public PeopleController(IPersonRepository personRepository)
        {
            _personRepository = personRepository;
        }

        [HttpPost]
        public async Task<IActionResult> CreatePerson(PersonCreateDto personCreateDto)
        {
            try
            {
                var person = await _personRepository.CreatePersonAsync(personCreateDto.ToPerson());

                return CreatedAtRoute(nameof(GetPersonByIdAsync), new { id = person.Id }, person.ToPersonDisplayDto());
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("{id}", Name = "GetPersonByIdAsync")]
        public async Task<IActionResult> GetPersonByIdAsync(int id)
        {
            try
            {
                var person = await _personRepository.GetPersonByIdAsync(id);
                if (person == null)
                {
                    return NotFound("Person with id " + id + " not found");
                }
                return Ok(person);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePersonAsync(int id, PersonUpdateDto personUpdateDto)
        {
            try
            {
                if (id != personUpdateDto.Id)
                {
                    return BadRequest("Ids mismatch");
                }
                var existingPerson = await _personRepository.GetPersonByIdAsync(id);
                if (existingPerson == null)
                {
                    return NotFound("Person with id " + id + " not found");
                }
                await _personRepository.UpdatePersonAsync(personUpdateDto.ToPerson());
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePersonAsync(int id)
        {
            try
            {
                var existingPerson = await _personRepository.GetPersonByIdAsync(id);
                if (existingPerson == null)
                {
                    return NotFound("Person with id " + id + " not found");
                }
                await _personRepository.DeletePersonAsync(id);
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetPeople()
        {
            try
            {
                var people = await _personRepository.GetAllPersonAsync();
                return Ok(people);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

    }
}