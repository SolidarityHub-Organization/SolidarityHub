public class App {

	public static void Main(string[] args) {
		var builder = WebApplication.CreateBuilder(args);

		BackendConfiguration.SetEnvironmentVariablesConfiguration();
		BackendConfiguration.SetCORSConfiguration(builder);
		BackendConfiguration.SetBuilderConfiguration(builder);
		BackendConfiguration.SetScopesConfiguration(builder);

		var app = builder.Build();

		BackendConfiguration.ExecuteAllMigrations(app);
		BackendConfiguration.SetGlobalExceptionHandlerConfiguration(app);
		BackendConfiguration.SetHTTPRequestPipelineConfiguration(app);

		app.Run();
	}

}


