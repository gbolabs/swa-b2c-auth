using api.Models;
using Microsoft.Extensions.Options;

namespace api.Providers
{
	public class AuthenticationProvider
	{
		AuthenticationConfig Config { get; set; }
		
		public AuthenticationProvider(IOptions<AuthenticationConfig> config)
		{
			ArgumentNullException.ThrowIfNull(config, nameof(config));

			Config = config.Value;

			if (string.IsNullOrWhiteSpace(Config.Username) || string.IsNullOrWhiteSpace(Config.Password))
			{
				Config = GenerateAuthentication();
			}
		}

		private static AuthenticationConfig GenerateAuthentication()
		{
			var userName = Guid.NewGuid();
			// Generate a random password
			var password = Guid.NewGuid();
			
			return new AuthenticationConfig
			{
				Username = userName.ToString(),
				Password = password.ToString(),
				IsGenerated = true
			};
		}

		public bool Authenticate(string username, string password) => username == Config.Username && password == Config.Password;
		
		public string GetUsername() => Config.IsGenerated ? Config.Username : "Provided by configuration";
		public string GetPassword() => Config.IsGenerated ? Config.Password : "Provided by configuration";
	}
}