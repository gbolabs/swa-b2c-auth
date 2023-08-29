using api.Models;
using api.Repository;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
	public static class B2CHooksController
	{
		public static WebApplication RegisterB2CHooksApis(this WebApplication app)
		{
			ArgumentNullException.ThrowIfNull(app);
			
			// Handle pre-token issuing hook
			app.MapPost("/api/b2c/pretoken", ([FromServices]Users users,
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

				return Results.Ok(new PreTokenB2CHookContinueResponse(Array.Empty<string>()));
			});
			
			app.MapPost("/api/b2c/validate", ([FromServices] Users users, ValidateB2cUserRequest validationRequest) =>
				{
					var exists = users.EmailList.Contains(validationRequest.Email);

					return exists
						? Results.Ok(new B2cValidationAdditionalClaimsResponse())
						: Results.Ok(new B2cValidationBlockResponse("User not found"));
				})
				.Produces<B2cValidationAdditionalClaimsResponse>()
				.Produces<B2cValidationBlockResponse>()
				.Accepts<ValidateB2cUserRequest>("application/json");
			
			return app;
		}
	}
}