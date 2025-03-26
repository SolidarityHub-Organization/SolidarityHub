using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;


// The controller is the entry point for the API. It is responsible for handling the incoming HTTP requests and sending the response back to the client.
// It must be attached to the service to be able to perform the necessary operations on the database, and to use the application's logic.

namespace LogicPersistence.Api.Controllers
{
    [Route("api/v1")]
    [ApiController]
    public class PeopleController : ControllerBase
    {
        private readonly IPersonServices _personServices;

        public PeopleController(IPersonServices personServices)
        {
            _personServices = personServices;
        }


        // The DTOs are the JSONs we are sending and recieveing from the database that are processed by the backend.


        //TODO: Change REST call names to standard REST conventions.
        //      Don't give verbose errors to the client. Instead, give a generic error message. Move the error messages from Services to Contoller.

        [HttpPost("users")]
        public async Task<IActionResult> CreatePerson(PersonCreateDto personCreateDto)
        {
            try
            {
                var person = await _personServices.CreatePerson(personCreateDto);
                return CreatedAtRoute(nameof(GetPersonByIdAsync), new { id = person.Id }, person);
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("users/{id}", Name = "GetUserById")]
        public async Task<IActionResult> GetPersonByIdAsync(int id)
        {
            try
            {
                var person = await _personServices.GetPersonByIdAsync(id);
                return Ok(person);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("users/{id}")]
        public async Task<IActionResult> UpdatePersonAsync(int id, PersonUpdateDto personUpdateDto)
        {
            try
            {
                var result = await _personServices.UpdatePersonAsync(id, personUpdateDto);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("users/{id}")]
        public async Task<IActionResult> DeletePersonAsync(int id)
        {
            try
            {
                await _personServices.DeletePersonAsync(id);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetPeople()
        {
            try
            {
                var people = await _personServices.GetPeopleAsync();
                return Ok(people);
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

    }
}