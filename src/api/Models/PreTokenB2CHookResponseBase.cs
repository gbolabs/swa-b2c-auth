namespace api.Models
{
	public abstract class PreTokenB2CHookResponseBase
	{
		public string Version { get; set; }
		public string Action { get; set; }
	}

	public class PreTokenB2CHookContinueResponse : PreTokenB2CHookResponseBase
	{
		public PreTokenB2CHookContinueResponse(string[] roles)
		{
			Version = "1.0.0";
			Action = "Continue";
		}
		
public string[] Roles { get; set; }	
	}
}