using api.Controllers;
using api.Models;
using api.Providers;
using api.Repository;
using Azure.Identity;
using Microsoft.Azure.KeyVault;
using Microsoft.Extensions.Configuration.AzureKeyVault;

var builder = WebApplication.CreateBuilder(args);

// Add configuration from environment variables
builder.Configuration.AddEnvironmentVariables();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry("APPINSIGHTS_INSTRUMENTATIONKEY");

// Register Swagger and OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<Users>();
builder.Services.AddSingleton<AuthenticationProvider>();
builder.Services.Configure<AuthenticationConfig>(builder.Configuration.GetSection("AuthenticationConfig"));

var app = builder.Build();

app.MapApiControllers();
app.UseSwagger();
app.UseSwaggerUI();

app.Run();
