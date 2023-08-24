using Microsoft.AspNetCore.Authorization.Infrastructure;

namespace api.Models
{
	public class UserInfo
	{
		public string Name { get; set; }
		public ClaimInfo[] Claims { get; set; }
	}

	public class ClaimInfo
	{
		public string Key { get; set; }
		public string Value { get; set; }
	}
}