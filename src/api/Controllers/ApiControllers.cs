using api.Helpers;
using api.Models;
using api.Providers;
using api.Repository;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers;

public static class ApiControllerMapper
{
	public static WebApplication MapApiControllers(this WebApplication app)
	{

		app.MapGet("/api/authentication/", ([FromServices] AuthenticationProvider authenticationProvider) =>
		{
			ArgumentNullException.ThrowIfNull(authenticationProvider, nameof(authenticationProvider));

			return Results.Ok(new
			{
				Username = authenticationProvider.GetUsername(),
				Password = authenticationProvider.GetPassword()
			});
		});
		
		return app;
	}
}