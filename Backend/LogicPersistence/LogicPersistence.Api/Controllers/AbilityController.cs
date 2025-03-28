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
        private readonly IAbilityServices _AbilityServices;

        public PeopleController(IAbilityServices AbilityServices)
        {
            _AbilityServices = AbilityServices;
        }


        // The DTOs are the JSONs we are sending and recieveing from the database that are processed by the backend.


        //TODO: Change REST call names to standard REST conventions.
        //      Don't give verbose errors to the client. Instead, give a generic error message. Move the error messages from Services to Contoller.

        [HttpPost("ability")]
        public async Task<IActionResult> CreateAbility(AbilityCreateDto AbilityCreateDto)
        {
            try
            {
                var Ability = await _AbilityServices.CreateAbility(AbilityCreateDto);
                return CreatedAtRoute(nameof(GetAbilityByIdAsync), new { id = Ability.Id }, Ability);
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

        [HttpGet("ability/{id}", Name = "GetAbilityById")]
        public async Task<IActionResult> GetAbilityByIdAsync(int id)
        {
            try
            {
                var Ability = await _AbilityServices.GetAbilityByIdAsync(id);
                return Ok(Ability);
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

        [HttpPut("ability/{id}")]
        public async Task<IActionResult> UpdateAbilityAsync(int id, AbilityUpdateDto AbilityUpdateDto)
        {
            try
            {
                var result = await _AbilityServices.UpdateAbilityAsync(id, AbilityUpdateDto);
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

        [HttpDelete("ability/{id}")]
        public async Task<IActionResult> DeleteAbilityAsync(int id)
        {
            try
            {
                await _AbilityServices.DeleteAbilityAsync(id);
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

        [HttpGet("ability")]
        public async Task<IActionResult> GetPeople()
        {
            try
            {
                var people = await _AbilityServices.GetPeopleAsync();
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