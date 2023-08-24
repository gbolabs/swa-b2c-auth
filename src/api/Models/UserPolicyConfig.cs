namespace api.Models
{
	public class UserPolicyConfig
	{
		private List<UserConfig> Users { get; set; } = new();
	}

	public record UserConfig
	{
		public string Email { get; set; }
		public bool IsAllowed { get; set; } = true;
	}
}