using System.Reflection;

namespace api.Models
{
	public abstract class B2cValidationResponseBase
	{
		public string Version { get; set; }
		public string Action { get; set; }
	}

	public class B2cValidationAdditionalClaimsResponse : B2cValidationResponseBase
	{
		public B2cValidationAdditionalClaimsResponse()
		{
			Version = "1.0.0";
			Action = "Continue";
		}
	}

	public class B2cValidationBlockResponse : B2cValidationResponseBase
	{
		public B2cValidationBlockResponse(string userMessage)
		{
			Version = "1.0.0";
			Action = "ShowBlockPage";
			UserMessage = userMessage;
		}

		public string UserMessage { get; set; }
	}
}