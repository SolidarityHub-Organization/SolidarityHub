using System.ComponentModel.DataAnnotations;

public class VolunteerSkill {
	public int? volunteer_id { get; set; } // FK to Volunteer table, nullable because it can be a task requirement
	public int? skill_id { get; set; } // FK to Skill table, nullable because it can be a task requirement
}
