namespace api.Models
{
	
	public record ValidateB2cUserRequestIdentity(string SignInType, string Issuer, string IssuerAssignedId
	);

	public record ValidateB2cUserRequest(
		string step,
		string client_id,
		string ui_locales,
		string Email,
		string Surname,
		string GivenName,
		List<ValidateB2cUserRequestIdentity> Identities
	);
	namespace YourNamespace
	{
		public record Identity
		{
			public string SignInType { get; init; }
			public string Issuer { get; init; }
			public string IssuerAssignedId { get; init; }
		}

		public record RequestData
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
	}


}