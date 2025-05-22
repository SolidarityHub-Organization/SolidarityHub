using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum UrgencyLevel {
	[Display(Name = "Desconocido")]
	Unknown = -1,
	[Display(Name = "Bajo")]
	Low = 0,
	[Display(Name = "Medio")]
	Medium = 1,
	[Display(Name = "Alto")]
	High = 2,
	[Display(Name = "Crítico")]
	Critical = 3
}

public class Need { // these specific needs that can be of a certain need type
					// a victim can set a task for themselves might be able to create a task through a need?
	public int id { get; set; }

	public string name { get; set; } = string.Empty;

	public string description { get; set; } = string.Empty;

	public UrgencyLevel urgencyLevel { get; set; }

	public string status { get; set; } = string.Empty ;

	// FKs
	// a need can be set by an admin or a victim (one is null)
	public int? victim_id { get; set; }
	public int? admin_id { get; set; }
	public DateTime created_at { get; set; }
	public int? need_type_id { get; set; } // FK to NeedType

	// Navigation properties

	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
	//public virtual Victim Victim { get; set; }
	//public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();
	//public virtual ICollection<NeedType> NeedTypes { get; set; } = new List<NeedType>();

	// admins can set needs unrelated to victims
	//public virtual Admin? Admin { get; set; }
}
