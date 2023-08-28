namespace api.Models
{
	public class PreTokenB2cHookRequest
	{
		public string Email { get; init; }
		public List<Identity> Identities { get; init; }
		public string DisplayName { get; init; }
		public string ObjectId { get; init; }
		public string ExtensionAttribute1 { get; init; }
		public string ExtensionAttribute2 { get; init; }
		public string ClientId { get; init; }
		public string Step { get; init; }
		public string UiLocales { get; init; }
	}
		public record Identity
		{
			public string SignInType { get; init; }
			public string Issuer { get; init; }
			public string IssuerAssignedId { get; init; }
		}
}