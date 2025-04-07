using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;
using Microsoft.AspNetCore.Mvc;


namespace LogicPersistence.Api.Controllers {

    [Route("api/v1")]
    [ApiController]
    public class TaskController(ITaskServices taskServices) : ControllerBase {
        private readonly ITaskServices _taskServices = taskServices;

        [HttpPost("tasks")]
        public async Task<IActionResult> CreateTaskAsync(TaskCreateDto taskCreateDto) {
            try {
                var task = await _taskServices.CreateTaskAsync(taskCreateDto);
                return CreatedAtRoute("GetTaskById", new { id = task.id }, task);
            } catch (ArgumentNullException ex) {
                return BadRequest(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("tasks/{id}", Name = "GetTaskById")]
        public async Task<IActionResult> GetTaskByIdAsync(int id) {
            try {
                var task = await _taskServices.GetTaskByIdAsync(id);
                return Ok(task);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpPut("tasks/{id}")]
        public async Task<IActionResult> UpdateTaskAsync(int id, TaskUpdateDto taskUpdateDto) {
            try {
                var result = await _taskServices.UpdateTaskAsync(id, taskUpdateDto);
                return Ok(result);
            } catch (ArgumentException ex) {
                return BadRequest(ex.Message);
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpDelete("tasks/{id}")]
        public async Task<IActionResult> DeleteTAsync(int id) {
            try {
                await _taskServices.DeleteTaskAsync(id);
                return NoContent();
            } catch (KeyNotFoundException ex) {
                return NotFound(ex.Message);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        [HttpGet("tasks")]
        public async Task<IActionResult> GetAllTasksAsync() {
            try {
                var tasks = await _taskServices.GetAllTasksAsync();
                return Ok(tasks);
            } catch (InvalidOperationException ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            } catch (Exception ex) {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
    }
}
