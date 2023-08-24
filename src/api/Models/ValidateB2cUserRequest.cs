namespace api.Models
{
	
	public record ValidateB2cUserRequestIdentity(
		string SignInType,
		string Issuer,
		string IssuerAssignedId
	);

	public record ValidateB2cUserRequest(
		string Email,
		IReadOnlyList<ValidateB2cUserRequestIdentity> Identities,
		string DisplayName,
		string ObjectId,
		string GivenName,
		string Surname,
		string JobTitle,
		string StreetAddress,
		string City,
		string PostalCode,
		string State,
		string Country,
		string Step,
		string ClientId,
		string UiLocales
	);


}