using LogicPersistence.Api.Models;
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
				return Ok(await _taskServices.GetAllTasksAsync());
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks-with-details")]
		public async Task<IActionResult> GetAllTasksWithDetailsAsync() {
			try {
				return Ok(await _taskServices.GetAllTasksWithDetailsAsync());
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// dictionary of state and task ids e.g. { "Completed": [1, 2], "Pending": [3, 4] }
		[HttpGet("tasks/states")]
		public async Task<IActionResult> GetTasksWithStatesAsync() {
			try {
				var stateTasks = await _taskServices.GetAllTaskIdsWithStatesAsync();
				return Ok(stateTasks);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/states/{id}")]
		public async Task<IActionResult> GetTaskStateByIdAsync(int id) {
			try {
				var stateTasks = await _taskServices.GetTaskStateByIdAsync(id);
				return Ok(stateTasks);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// dictionary of state and task count e.g. { "Completed": 2, "Pending": 4 }
		[HttpGet("tasks/states/count")]
		public async Task<IActionResult> GetAllTaskCountByStateAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
			try {
				var stateCounts = await _taskServices.GetAllTaskCountByStateAsync(fromDate, toDate);
				return Ok(stateCounts);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// returns the count of tasks depending on the state e.g. 2
		[HttpGet("tasks/states/{state}/count")]
		public async Task<IActionResult> GetTaskCountByStateAsync([FromRoute] string state, [FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
			try {
				var count = await _taskServices.GetTaskCountByStateAsync(state, fromDate, toDate);
				return Ok(count);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// returns a list of task ids depending on the state e.g. [1, 2, 3]
		[HttpGet("tasks/states/{state}/ids")]
		public async Task<IActionResult> GetTaskIdsByStateAsync([FromRoute] string state) {
			try {
				var taskIds = await _taskServices.GetTaskIdsByStateAsync(state);
				return Ok(taskIds);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/dashboard")]
		public async Task<IActionResult> GetAllTasksForDashboardAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
			try {
				return Ok(await _taskServices.GetAllTasksForDashboardAsync(fromDate, toDate));
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/by-state")]
		public async Task<IActionResult> GetTasksByStateAsync([FromQuery] string state, [FromQuery] DateTime fromDate, [FromQuery] DateTime toDate) {
			try {
				return Ok(await _taskServices.GetTasksByStateAsync(state, fromDate, toDate));
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// Returns a list of all the tasks which are assigned to a volunteer
		[HttpGet("tasks/assigned-to-volunteer/{volunteerId}")]
		public async Task<IActionResult> GetTasksAssignedToVolunteerAsync(int volunteerId) {
			try {
				return Ok(await _taskServices.GetTasksAssignedToVolunteerAsync(volunteerId));
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// Returns a list of task which are assigned to a volunteer and are in the pending state meaning they still havent been accepted or refused by the volunteer
		[HttpGet("tasks/assigned-to-volunteer/pending/{volunteerId}")]
		public async Task<IActionResult> GetPendingTasksAssignedToVolunteerAsync(int volunteerId) {
			try {
				return Ok(await _taskServices.GetPendingTasksAssignedToVolunteerAsync(volunteerId));
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
		// Returns a list of task which are assigned to a volunteer and are in the assigned state meaning they where accepted by the volunteer
		[HttpGet("tasks/assigned-to-volunteer/assigned/{volunteerId}")]
		public async Task<IActionResult> GetAssignedTasksAssignedToVolunteerAsync(int volunteerId) {
			try {
				return Ok(await _taskServices.GetAssignedTasksAssignedToVolunteerAsync(volunteerId));
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		// Lets you modify the state of a task for a volunteer
		[HttpPut("tasks/assigned-to-volunteer/{volunteerId}/{taskId}")]
		public async Task<IActionResult> UpdateTaskStateForVolunteerAsync(int volunteerId, int taskId, UpdateTaskStateDto updateTaskStateDto) {
			if (updateTaskStateDto == null) {
				return BadRequest("State cannot be null.");
			}
			try {
				var task = await _taskServices.UpdateTaskStateForVolunteerAsync(volunteerId, taskId, updateTaskStateDto);
				return Ok();
				//TODO: return the task with the new state correctly
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/{taskId}/urgency_level")]
		public async Task<IActionResult> GetMaxUrgencyLevelForTaskAsync(int taskId) {
			try {
				var urgencyLevel = await _taskServices.GetMaxUrgencyLevelForTaskAsync(taskId);
				return Ok(urgencyLevel);
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/paginated")]
		public async Task<IActionResult> GetPaginatedTasksAsync([FromQuery] int page = 1, [FromQuery] int size = 10) {
			try {
				var (tasks, totalCount) = await _taskServices.GetPaginatedTasksAsync(page, size);

				return Ok(new {
					Items = tasks,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				});
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}
		
		[HttpGet("tasks/dashboard/paginated")]
		public async Task<IActionResult> GetPaginatedTasksForDashboardAsync([FromQuery] DateTime fromDate, [FromQuery] DateTime toDate, [FromQuery] int page = 1, [FromQuery] int size = 10) {
			try {
				var (tasks, totalCount) = await _taskServices.GetPaginatedTasksForDashboardAsync(fromDate, toDate, page, size);
				
				return Ok(new
				{
					Items = tasks,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				});
			} catch (ArgumentException ex) {
				return BadRequest(ex.Message);
			} catch (InvalidOperationException ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			} catch (Exception ex) {
				return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
			}
		}

		[HttpGet("tasks/{taskId}/volunteers/paginated")]
		public async Task<IActionResult> GetPaginatedVolunteersForTaskAsync(
			[FromRoute] int taskId,
			[FromQuery] DateTime fromDate,
			[FromQuery] DateTime toDate,
			[FromQuery] int page = 1,
			[FromQuery] int size = 10)
		{
			try
			{
				var (volunteers, totalCount) = await _taskServices.GetTaskVolunteersPaginatedByDateRangeAsync(
					taskId, fromDate, toDate, page, size);

				return Ok(new
				{
					Items = volunteers,
					TotalCount = totalCount,
					PageNumber = page,
					PageSize = size,
					TotalPages = (int)Math.Ceiling(totalCount / (double)size)
				});
			}
			catch (ArgumentException ex)
			{
				return BadRequest(ex.Message);
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

		[HttpPost("tasks/{taskId}/assign-volunteers")]
		public async Task<IActionResult> AssignVolunteersToTask(
			int taskId, 
			[FromBody] AssignVolunteersRequest request)
		{
			try
			{
				// Add validation logging
				Console.WriteLine($"TaskId: {taskId}");
				Console.WriteLine($"VolunteerIds: [{string.Join(", ", request.volunteer_ids)}]");
				Console.WriteLine($"State: {request.state}");

				await _taskServices.AssignVolunteersToTaskAsync(taskId, request.volunteer_ids, request.state);
				return Ok(new { message = "Volunteers assigned successfully" });
			}
			catch (ArgumentException ex)
			{
				Console.WriteLine($"ArgumentException: {ex.Message}");
				return BadRequest(new { error = ex.Message });
			}
			catch (Exception ex)
			{
				Console.WriteLine($"Exception: {ex.Message}");
				Console.WriteLine($"StackTrace: {ex.StackTrace}");
				return StatusCode(500, new { error = ex.Message }); // Return actual error message
			}
		}
	}
}
