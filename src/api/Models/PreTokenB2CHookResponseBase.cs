using System.Text.Json.Serialization;

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
			AppRoles = roles;
		} 
		/// <summary>
		/// Returns the application roles serialized as csv string named extension_AppRoles
		/// </summary>
		[JsonIgnore]
		private string[] AppRoles { get; }
		
		[JsonPropertyName("extension_AppRoles")]
		public string AppRolesCsv => string.Join(",", AppRoles);
	}
}