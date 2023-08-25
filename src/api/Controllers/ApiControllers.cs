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
		app.MapGet("/api/user/current", ([FromServices]IHttpContextAccessor accessor) =>
		{
			ArgumentNullException.ThrowIfNull(accessor.HttpContext);
			
			var data = accessor.HttpContext.Request.Parse();
			
			ArgumentNullException.ThrowIfNull(data.Identity);
			
			return new
			{
				UserId = data.Identity.Name,
				Claims = data.Claims.Select(c => new { type = c.Type, value = c.Value }).ToList()
			};
		}).Produces<UserInfo>().WithDescription("Returns the current user info");
		
		app.MapGet("/api/user/roles", () => new List<string>
		{
			"PlatfromAdmin",
			"ServiceProviderAdmin",
			"User",
		}).Produces<List<string>>()
			.WithDescription("Returns all available roles");

		app.MapPost("/api/user/validate", ([FromServices]Users users, ValidateB2cUserRequest validationRequest) =>
			{
				var exists = users.EmailList.Contains(validationRequest.Email);
				
				return exists
					? Results.Ok(new B2cValidationAdditionalClaimsResponse())
					: Results.Ok(new B2cValidationBlockResponse("User not found"));
			})
			.Produces<B2cValidationAdditionalClaimsResponse>()
			.Produces<B2cValidationBlockResponse>()
			.Accepts<ValidateB2cUserRequest>("application/json");
		
		app.MapGet("/api/users",([FromServices]Users users)=> users.EmailList.ToArray())
			.Produces<string[]>()
			.WithDescription("Returns all available users");

		app.MapPost("/api/users", ([FromServices] Users users) =>
		{
			ArgumentNullException.ThrowIfNull(users);

			users.EmailList.Clear();

			return Results.Ok(users.EmailList.Count);
		}).Accepts<string[]>("application/json").Produces<int>().WithDescription("Sets all available users");
		
		app.MapDelete("/api/users/email", ([FromServices] Users users, string email) =>
		{
			ArgumentNullException.ThrowIfNull(users);

			var done = users.EmailList.Remove(email);

			return done ? Results.Ok() : Results.NoContent();
		}).WithDescription("Removes a user");
		
		app.MapPost($"/api/users/email", ([FromServices] Users users, string email) =>
			{
				ArgumentNullException.ThrowIfNull(users);
				if(string.IsNullOrWhiteSpace(email))
				{
					return Results.BadRequest("Email is required");
				}

				if (users.EmailList.Contains(email))
				{
					return Results.Conflict("Email already exists");
				}
				
				users.EmailList.Add(email);
				return Results.Accepted();
			})
			.Accepts<string>("application/json")
			.Produces<int>()
			.WithDescription("Adds a user");

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