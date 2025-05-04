using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum DayOfWeek {
	[Display(Name = "Lunes")]
	Monday = 0,
	[Display(Name = "Martes")]
	Tuesday = 1,
	[Display(Name = "Miércoles")]
	Wednesday = 2,
	[Display(Name = "Jueves")]
	Thursday = 3,
	[Display(Name = "Viernes")]
	Friday = 4,
	[Display(Name = "Sábado")]
	Saturday = 5,
	[Display(Name = "Domingo")]
	Sunday = 6
}

public abstract class Time {
	public int id { get; set; }
	public TimeOnly start_time { get; set; }
	public TimeOnly end_time { get; set; }
	//public TimeOnly? end_time { get; set; }	//TODO
}

public class TaskTime : Time {
	public DateOnly date { get; set; }
	//public DateOnly start_date { get; set; }	//TODO
	//public DateOnly? end_date { get; set; }

	// FKs
	public int task_id { get; set; }


	// Navigation properties

	//public virtual Task Task { get; set; }
}

public class VolunteerTime : Time {
	public DayOfWeek day { get; set; }

	// FKs
	public int volunteer_id { get; set; }


	// Navigation properties

	//public virtual Volunteer Volunteer { get; set; }
}
