using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum SkillLevel {
	[Display(Name = "Desconocido")]
	Unknown = -1,
	[Display(Name = "Principiante")]
	Beginner = 0,
	[Display(Name = "Intermedio")]
	Intermediate = 1,
	[Display(Name = "Experto")]
	Expert = 2
}

public class Skill {
	public int id { get; set; }

	public string name { get; set; } = string.Empty;

	// volunteer can pick which skill level they have, or task can require a skill level
	public SkillLevel level { get; set; }


	// FKs
	public int admin_id { get; set; }


	// Navigation properties

	public virtual ICollection<Task> Tasks { get; set; } = [];
	public virtual ICollection<Volunteer> Volunteers { get; set; } = [];
	public virtual ICollection<Need> Needs { get; set; } = [];

	// admins set the skills you can pick from
	public virtual Admin? Admin { get; set; }
}
