public class App {

	public static void Main(string[] args) {
		var builder = WebApplication.CreateBuilder(args);
		var app = builder.Build();

		Start(app, builder);
	}

	public static void Start(WebApplication app, WebApplicationBuilder builder) {
		BackendConfiguration.SetEnvironmentVariablesConfiguration();
		BackendConfiguration.SetCORSConfiguration(builder);
		BackendConfiguration.SetBuilderConfiguration(builder);
		BackendConfiguration.SetScopesConfiguration(builder);
		BackendConfiguration.SetGlobalExceptionHandlerConfiguration(app);
		BackendConfiguration.SetHTTPRequestPipelineConfiguration(app);

		app.Run();
	}

}


