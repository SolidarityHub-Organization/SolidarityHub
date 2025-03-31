namespace LogicPersistence.Api.Models;

public enum SkillLevel {
	Principiante = 0,
	Intermedio = 1,
	Avanzado = 2
}

public class Skill {
	public int id { get; set; }

	public required string name { get; set; }

	// volunteer can pick which skill level they have, or task can require a skill level
	public SkillLevel level { get; set; }


	// FKs
	public int admin_id { get; set; }

	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
	//public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
	//public virtual ICollection<Need> Needs { get; set; } = new List<Need>();

	// admins set the skills you can pick from
	//public virtual Admin Admin { get; set; }
}
