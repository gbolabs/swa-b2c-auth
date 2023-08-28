using api.Models;
using api.Repository;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
	public static class B2cHooksController
	{
		public static WebApplication RegisterB2cHooksApis(this WebApplication app)
		{
			ArgumentNullException.ThrowIfNull(app);
			
			// Handle pre-token issuing hook
			app.MapPost("/api/b2c/pretoken", ([FromServices]Users users,
				ILogger logger,
				PreTokenB2cHookRequest request) =>
			{
				ArgumentNullException.ThrowIfNull(users);
				ArgumentNullException.ThrowIfNull(request);
				
				if(string.IsNullOrWhiteSpace(request.Email))
				{
					return Results.BadRequest("Email is required");
				}

				if (users.Roles.TryGetValue(request.Email, out var roles))
				{
					return Results.Ok(new PreTokenB2CHookContinueResponse(roles));
				}

				logger.LogWarning("Roles not found");
				return Results.Ok(new PreTokenB2CHookContinueResponse(Array.Empty<string>()));
			});

			return app;
		}
	}
}