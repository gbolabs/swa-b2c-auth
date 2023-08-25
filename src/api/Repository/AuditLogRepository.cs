using api.Models;

namespace api.Repository
{
	public class AuditLogRepository
	{
		
		public List<AuditLogEntry> Entries { get; set; } = new();
	}
}