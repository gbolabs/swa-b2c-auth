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


}