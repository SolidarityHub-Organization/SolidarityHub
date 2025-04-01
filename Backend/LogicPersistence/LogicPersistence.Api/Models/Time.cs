using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum DayOfWeek {
	[Display(Name = "Lunes")]
	Monday,
	[Display(Name = "Martes")]
	Tuesday,
	[Display(Name = "Miércoles")]
	Wednesday,
	[Display(Name = "Jueves")]
	Thursday,
	[Display(Name = "Viernes")]
	Friday,
	[Display(Name = "Sábado")]
	Saturday,
	[Display(Name = "Domingo")]
	Sunday
}

public class Time {
	// time_slot and day form primary key, we must be able to pick amongst all time combinatios (with a combo box for example)
	public DateTime start_time { get; set; }
	public DateTime end_time { get; set; }
	public DayOfWeek day { get; set; }  // lunes, martes, miércoles, jueves, viernes, sábado, domingo

	// FKs

	// instead of using the volunteer list below, we query the database for the volunteers that have this time preference when needed to avoid keeping a giant list of volunteers in memory
	//public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
}
