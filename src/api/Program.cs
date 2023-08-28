using api;
using api.Controllers;
using api.Models;
using api.Providers;
using api.Repository;
using Azure.Identity;
using Microsoft.AspNetCore.HttpLogging;
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
builder.Services.AddSingleton<AuditLogRepository>();
builder.Services.Configure<AuthenticationConfig>(builder.Configuration.GetSection("AuthenticationConfig"));
builder.Services.AddHttpLogging(options =>
{
	options.LoggingFields = HttpLoggingFields.All;
	options.RequestBodyLogLimit = 4096;
	options.ResponseBodyLogLimit = 4096;
});

var app = builder.Build();


// Log all requests
app.UseHttpLogging();

app.Use(async (context, func) =>
{
	context.RequestServices.GetRequiredService<AuditLogRepository>().Entries.Add(new AuditLogEntry
	{
		Id = Guid.NewGuid().ToString(),
		Url = context.Request.Path,
		Timestamp = DateTime.UtcNow,
		UserId = context.User.Identity?.Name ?? string.Empty,
		// Get source IP
		SourceIp = context.Connection.RemoteIpAddress?.ToString() ?? string.Empty
	});
	await func.Invoke();
});
app.MapApiControllers();
app.MapAuditLogController();
app.RegisterUserApis();
app.RegisterB2CHooksApis();
app.UseSwagger(options =>
{
	options.RouteTemplate = "api/{documentName}/swagger.json";
});
app.UseSwaggerUI(options =>
{
	options.SwaggerEndpoint("/api/v1/swagger.json", "API v1");
	options.DocumentTitle = "B2C Login Testing API";
	options.RoutePrefix = "api";
});
app.UseHttpsRedirection();

// In case of development, use the local development certificate
if (app.Environment.IsDevelopment())
{
	app.UseDeveloperExceptionPage();
}

app.Run();
