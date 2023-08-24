namespace api.Models
{
	public class AuthenticationConfig
	{
		public string Username { get; set; }
		public string Password { get; set; }

		public bool IsGenerated { get; set; } = false;
	}
}