using api.Models;
using api.Repository;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
	public static class AuditLogController
	{
		public static WebApplication MapAuditLogController(this WebApplication app)
		{
			app.MapGet("/api/auditlog", ([FromServices]AuditLogRepository auditLogRepository) 
				=> auditLogRepository.Entries);
			app.MapGet("/api/auditlog/{id}", ([FromServices]AuditLogRepository auditLogRepository, string id) 
				=> auditLogRepository.Entries.FirstOrDefault(e => e.Id == id));
			app.MapDelete("/api/auditlog/{id}", ([FromServices]AuditLogRepository auditLogRepository, string id) =>
			{
				var entry = auditLogRepository.Entries.FirstOrDefault(e => e.Id == id);
				auditLogRepository.Entries.Remove(entry);
				return entry;
			});
			app.MapDelete("/api/auditlog", ([FromServices]AuditLogRepository auditLogRepository) =>
			{
				auditLogRepository.Entries.Clear();
				return auditLogRepository.Entries;
			});
			app.MapPost("/api/auditlog", ([FromServices]AuditLogRepository auditLogRepository, AuditLogEntry entry) =>
			{
				auditLogRepository.Entries.Add(entry);
				return entry;
			});
			return app;
		}
	}
}