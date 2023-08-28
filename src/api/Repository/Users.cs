namespace api.Repository
{
	public class Users
	{
		public List<string> EmailList { get; } = new();

		public Dictionary<string, string[]> Roles { get; } = new(); // key is email, value is array of roles
	}
}