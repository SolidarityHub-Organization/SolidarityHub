using System.ComponentModel.DataAnnotations;
using DapperPostgresDemo.Api.Repositories;
using System;
using DotNetEnv;


var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
var envFile = $".env.{environment.ToLowerInvariant()}";
var envPath = Path.Combine(Directory.GetCurrentDirectory(), envFile);

if (File.Exists(envPath)) {
    Env.Load(envPath);
} else {
    throw new FileNotFoundException($"Environment file not found: {envPath}");
}

Console.WriteLine(Environment.GetEnvironmentVariable("POSTGRES_HOST"));
string CONNECTION_STRING = $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};" +
                        $"Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};" +
                        $"Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};" +
                        $"Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};" +
                        $"Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}";
Console.WriteLine(CONNECTION_STRING);


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IPersonRepository, PersonRepository>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
