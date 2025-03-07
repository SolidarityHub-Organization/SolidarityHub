using System.Diagnostics;
using System.Runtime.ConstrainedExecution;
using Dapper;
using DotNetEnv;
using FluentMigrator.Runner;
using Npgsql;

var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
var envFile = $".env.{environment.ToLowerInvariant()}";
var envPath = Path.Combine(Directory.GetCurrentDirectory(), envFile);

if (File.Exists(envPath)) {
    Env.Load(envPath);
} else {
    throw new FileNotFoundException($"Environment file not found: {envPath}");
}

var builder = WebApplication.CreateBuilder(args);

string CONNECTION_STRING = $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};" +
                        $"Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};" +
                        $"Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};" +
                        $"Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};" +
                        $"Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}";


// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddFluentMigratorCore()
    .ConfigureRunner(rb => rb
        .AddPostgres()
        .WithGlobalConnectionString(CONNECTION_STRING)
        .ScanIn(typeof(Program).Assembly).For.Migrations())
    .AddLogging(lb => lb.AddFluentMigratorConsole());

builder.Services.AddCors(options => {
    options.AddPolicy("AllowAll",
        builder => {
            builder
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
});

var app = builder.Build();
using var scope = app.Services.CreateScope();
var migrator = scope.ServiceProvider.GetService<IMigrationRunner>();
migrator?.MigrateUp();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment()) {
    app.MapOpenApi();
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();

var summaries = new[] {
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/api/v1/get-example-data", () => {
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.MapPost("/api/v1/insert-user-test", async () => {
    var newUser = new UserTest {
        Id = 1,
        Name = "test_name",
        Test = 12345,
    };

    var dapperTest = new DapperTest(CONNECTION_STRING);
    await dapperTest.AddUser(newUser);
});

app.MapGet("/api/v1/get-users-test", async () => {
    var dapperTest = new DapperTest(CONNECTION_STRING);
    return await dapperTest.GetAllUsers();
});

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary) {
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}

public class DapperTest {
    private NpgsqlConnection? connection;

    public DapperTest(string connectionString) {
        InitializeConnection(connectionString);
    }

    private void InitializeConnection(string connectionString) {
        connection = new NpgsqlConnection(connectionString);
        connection.Open();
    }

    public async Task AddUser(UserTest user) {
        if (connection is null || connection.State != System.Data.ConnectionState.Open) {
            throw new InvalidOperationException("Database connection is not open");
        }

        string commandText = """
                            INSERT INTO "Users" ("Name", "Test") 
                            VALUES (@name, @test) 
        """;

        var queryArguments = new {
            name = user.Name,
            test = user.Test,
        };

        await connection.ExecuteAsync(commandText, queryArguments);
    }

    public void Dispose() {
        connection?.Dispose();
    }

    public async Task<IEnumerable<UserTest>> GetAllUsers() {
        string commandText = """
                            SELECT * FROM "Users"
                            """;

        if (connection is null || connection.State != System.Data.ConnectionState.Open) {
            throw new InvalidOperationException("Database connection is not open");
        }

        var users = await connection.QueryAsync<UserTest>(commandText);
        return users;
    }
}

public class UserTest 
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public int Test { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}
