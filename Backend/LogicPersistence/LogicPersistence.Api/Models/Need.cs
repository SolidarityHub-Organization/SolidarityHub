namespace LogicPersistence.Api.Models;

public enum UrgencyLevel {
	Bajo = 0,
	Medio = 1,
	Alto = 2,
	Critico = 3
}

public class Need {
	public int id { get; set; }

	public required string name { get; set; }

	public required string description { get; set; }

	public UrgencyLevel urgencyLevel { get; set; }

	// FKs
	public int admin_id { get; set; }

	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
	//public virtual ICollection<Victim> Victims { get; set; } = new List<Victim>();
	//public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();

	// admins can set needs unrelated to victims
	//public virtual Admin Admin { get; set; }
}
