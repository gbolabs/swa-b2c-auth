using System.Diagnostics.Tracing;

namespace api.Models
{
	/// <summary>
	/// Class to trace the audit log
	/// </summary>
	public class AuditLogEntry
	{
		public string Id { get; set; } = Guid.NewGuid().ToString();
		public string UserId { get; set; }
		public string UserName { get; set; }
		public string UserEmail { get; set; }
		public DateTime Timestamp { get; set; } = DateTime.UtcNow;
		public string Action { get; set; }
public string Resource { get; set; }
public PathString Url { get; set; }
public string SourceIp { get; set; }
public string Method { get; set; }
public Dictionary<string, string> Headers { get; set; }
public string Body { get; set; }
public string ResponseBody { get; set; }
public string ResponseStatusCode { get; set; }
	}
}