using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class TaskCreateDto {
	[Required]
	[MaxLength(255)]
	public string name { get; set; } = string.Empty;

	[Required]
	[MaxLength(1000)]
	public string description { get; set; } = string.Empty;

	public int? admin_id { get; set; }

	[Required]
	public int location_id { get; set; }

	[Required]
	public int[] volunteer_ids { get; set; } = [];

	[Required]
	public int[] victim_ids { get; set; } = [];
}

public class TaskUpdateDto {
	[Required]
	public int id { get; set; }

	[Required]
	[MaxLength(255)]
	public string name { get; set; } = string.Empty;

	[Required]
	[MaxLength(1000)]
	public string description { get; set; } = string.Empty;

	public int? admin_id { get; set; }

	[Required]
	public int location_id { get; set; }

	[Required]
	public int[] volunteer_ids { get; set; } = [];

	[Required]
	public int[] victim_ids { get; set; } = [];
}

public class TaskDisplayDto {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	public int? admin_id { get; set; }
	public int location_id { get; set; }
    public DateTime created_at { get; set; } 
}

public class TaskWithDetailsDto {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	public int? admin_id { get; set; }
	public int location_id { get; set; }
	// Temporaryly using string to store JSON data as dapper
	// does not support deserializing JSON to a list of objects directly.
	public string assigned_volunteersJson { get; set; } = "[]";
	public IEnumerable<VolunteerDisplayDto> assigned_volunteers { get; set; } = [];
	public string assigned_victimsJson { get; set; } = "[]";
	public IEnumerable<VictimDisplayDto> assigned_victims { get; set; } = [];
}

public class TaskForDashboardDto {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public String urgency_level { get; set; } = string.Empty;
	public String state { get; set; } = string.Empty;
	public AffectedZoneWithPointsDTO? affected_zone { get; set; }
}
