using DotNetEnv;
using FluentMigrator.Runner;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;

public static class DatabaseConfiguration {
	public static string GetConnectionString() {
		return $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};" +
			   $"Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};" +
			   $"Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};" +
			   $"Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};" +
			   $"Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}";
	}
}

public static class BackendConfiguration {

	public static void SetEnvironmentVariablesConfiguration() {
		var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
		var envFile = $".env.{environment.ToLowerInvariant()}";
		var envPath = Path.Combine(Directory.GetCurrentDirectory(), envFile);

		if (File.Exists(envPath)) {
			Env.Load(envPath);
		} else {
			throw new FileNotFoundException($"Environment variables file not found: {envPath}");
		}
	}

	public static void SetBuilderConfiguration(WebApplicationBuilder builder) {
		builder.Services.AddControllers();
		builder.Services.AddEndpointsApiExplorer();
		builder.Services.AddSwaggerGen();
		builder.Services.AddControllers().AddNewtonsoftJson();
		SetMigrationConfiguration(builder);
	}

	private static void SetMigrationConfiguration(WebApplicationBuilder builder) {
		builder.Services.AddFluentMigratorCore()
		.ConfigureRunner(rb => rb
			.AddPostgres()
			.WithGlobalConnectionString(DatabaseConfiguration.GetConnectionString())
			.ScanIn(typeof(DatabaseConfiguration).Assembly).For.Migrations())
		.AddLogging(lb => lb.AddFluentMigratorConsole());
	}

	public static void SetCORSConfiguration(WebApplicationBuilder builder) {
		// TODO: In production, restrict the CORS policy to not allow every source, it's ok for development
		builder.Services.AddCors(options => {
			options.AddPolicy("AllowAll", policy => {
				policy.AllowAnyOrigin()
					  .AllowAnyMethod()
					  .AllowAnyHeader();
			});
		});
	}

	public static void ExecuteAllMigrations(WebApplication app) {
		using var scope = app.Services.CreateScope();
		var migrator = scope.ServiceProvider.GetService<IMigrationRunner>();
		migrator?.MigrateUp();
	}

	public static void SetGlobalExceptionHandlerConfiguration(WebApplication app) {
		if (app.Environment.IsDevelopment()) {
			app.UseDeveloperExceptionPage();
		} else {
			app.UseExceptionHandler("/error");
			app.UseHsts();
		}

		app.UseHttpsRedirection();
		app.UseRouting();
		app.UseMiddleware<GlobalExceptionMiddleware>();
		app.UseAuthorization();
		app.MapControllers();
	}

	public static void SetHTTPRequestPipelineConfiguration(WebApplication app) {
		if (app.Environment.IsDevelopment()) {
			app.UseSwagger();
			app.UseSwaggerUI();
		}

		app.UseCors("AllowAll");
		app.UseHttpsRedirection();
		app.UseAuthorization();
		app.MapControllers();
	}

	public static void SetScopesConfiguration(WebApplicationBuilder builder) {
		builder.Services.AddScoped<IVictimRepository, VictimRepository>();
		builder.Services.AddScoped<IVictimServices, VictimServices>();
		builder.Services.AddScoped<IVolunteerRepository, VolunteerRepository>();
		builder.Services.AddScoped<IVolunteerServices, VolunteerServices>();
		builder.Services.AddScoped<ISkillRepository, SkillRepository>();
		builder.Services.AddScoped<ISkillServices, SkillService>();
		builder.Services.AddScoped<IAdminRepository, AdminRepository>();
		builder.Services.AddScoped<IAdminServices, AdminServices>();
		builder.Services.AddScoped<ITaskRepository, TaskRepository>();
		builder.Services.AddScoped<ITaskServices, TaskServices>();
		builder.Services.AddScoped<INeedRepository, NeedRepository>();
		builder.Services.AddScoped<INeedServices, NeedServices>();
		builder.Services.AddScoped<ILocationRepository, LocationRepository>();
		builder.Services.AddScoped<ILocationServices, LocationServices>();
		builder.Services.AddScoped<IGeneralRepository, GeneralRepository>();
		builder.Services.AddScoped<IGeneralServices, GeneralServices>();
		builder.Services.AddScoped<ILoginServices, LoginServices>();
	}

}
