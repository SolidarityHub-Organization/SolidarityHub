using FluentMigrator.Runner;

public class App {

	public static void Main(string[] args) {
		var builder = WebApplication.CreateBuilder(args);

		BackendConfiguration.SetEnvironmentVariablesConfiguration();
		BackendConfiguration.SetCORSConfiguration(builder);
		BackendConfiguration.SetBuilderConfiguration(builder);
		BackendConfiguration.SetScopesConfiguration(builder);

		var app = builder.Build();

		// Executing migrations at app startup
		using (var scope = app.Services.CreateScope()) {
			var migrator = scope.ServiceProvider.GetService<IMigrationRunner>();

			if (migrator != null) {
				migrator.MigrateUp();
			}
		}

		BackendConfiguration.SetGlobalExceptionHandlerConfiguration(app);
		BackendConfiguration.SetHTTPRequestPipelineConfiguration(app);

		app.Run();
	}

}


