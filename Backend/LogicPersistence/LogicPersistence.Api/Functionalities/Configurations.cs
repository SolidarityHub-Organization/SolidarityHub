using DotNetEnv;
using FluentMigrator.Runner;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;
using LogicPersistence.Api.Services.Interfaces;
using LogicPersistence.Api.Services.ObserverPattern;

public sealed class DatabaseConfiguration {
	private static DatabaseConfiguration? _instance;
	private static readonly object _lock = new object();
	private string? _connectionString;

	private DatabaseConfiguration() { }

	public static DatabaseConfiguration Instance {
		get {
			if (_instance == null) {
				lock (_lock) {
					_instance ??= new DatabaseConfiguration();
				}
			}
			return _instance;
		}
	}

	public string GetConnectionString() {
		if (_connectionString == null) {
			_connectionString = $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};" +
							  $"Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};" +
							  $"Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};" +
							  $"Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};" +
							  $"Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}";
		}
		return _connectionString;
	}

	public void ResetConnectionString() {
		_connectionString = null;
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
			.WithGlobalConnectionString(DatabaseConfiguration.Instance.GetConnectionString())
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

		// Register the TaskServices with the observer
		builder.Services.AddScoped<ITaskServices>(provider => {
			var repo = provider.GetRequiredService<ITaskRepository>();
			var locationRepo = provider.GetRequiredService<ILocationRepository>();
			var victimRepo = provider.GetRequiredService<IVictimRepository>();
			var volunteerRepo = provider.GetRequiredService<IVolunteerRepository>();
			var affectedZoneRepo = provider.GetRequiredService<IAffectedZoneRepository>();
			var pointRepo = provider.GetRequiredService<IPointRepository>();
			var paginationService = provider.GetRequiredService<IPaginationService>();
			var taskServices = new TaskServices(repo, locationRepo, victimRepo, volunteerRepo, affectedZoneRepo, pointRepo, paginationService);
			var observer = provider.GetRequiredService<VolunteerNotificationObserver>();
			taskServices.RegisterObserver(observer);
			return taskServices;
		});

		builder.Services.AddScoped<INeedRepository, NeedRepository>();
		builder.Services.AddScoped<INeedServices, NeedServices>();
		builder.Services.AddScoped<ILocationRepository, LocationRepository>();
		builder.Services.AddScoped<ILocationServices, LocationServices>();
		builder.Services.AddScoped<IGeneralRepository, GeneralRepository>();
		builder.Services.AddScoped<IGeneralServices, GeneralServices>();
		builder.Services.AddScoped<ILoginServices, LoginServices>();
		builder.Services.AddScoped<ISignupServices, SignupServices>();
		builder.Services.AddScoped<IDonationRepository, DonationRepository>();
		builder.Services.AddScoped<IDonationServices, DonationServices>();
		builder.Services.AddScoped<IAffectedZoneRepository, AffectedZoneRepository>();
		builder.Services.AddScoped<IAffectedZoneServices, AffectedZoneServices>();
		builder.Services.AddScoped<IMapServices, MapServices>();
		builder.Services.AddScoped<IDashboardServices, DashboardServices>();
		builder.Services.AddScoped<IPointServices, PointServices>();
		builder.Services.AddScoped<IPointRepository, PointRepository>();
		builder.Services.AddScoped<IMapServices, MapServices>();
		builder.Services.AddScoped<IMapStrategy<AffectedZoneWithPointsDTO>, HeatMapStrategy>();
		builder.Services.AddScoped<MapStrategyServices>();
		builder.Services.AddScoped<INotificationService, NotificationService>();
		builder.Services.AddScoped<VolunteerNotificationObserver>();
		builder.Services.AddScoped<IPaginationRepository, PaginationRepository>();
		builder.Services.AddScoped<IPaginationService, PaginationService>();

	}
}
