using Newtonsoft.Json;
using System.Net;

public class CustomException : Exception {
	public CustomException(string message) : base(message) {
	}

}

public class GlobalExceptionMiddleware {
	private readonly RequestDelegate _next;

	public GlobalExceptionMiddleware(RequestDelegate next) {
		_next = next;
	}

	public async Task InvokeAsync(HttpContext context) {
		try {
			await _next(context);
		} catch (Exception ex) {
			await HandleExceptionAsync(context, ex);
		}
	}

	private static Task HandleExceptionAsync(HttpContext context, Exception ex) {
		context.Response.ContentType = "application/json";
		context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

		var response = new {
			error = new {
				message = "An error occurred while processing your request.",
				details = ex.Message
			}
		};

		return context.Response.WriteAsync(JsonConvert.SerializeObject(response));
	}
}
