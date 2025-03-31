namespace LogicPersistence.Api.Models;

public enum TimeSlot {
	Mañana,
	Tarde,
	Noche,
	DiaCompleto,
	Madrugada
}

public enum DayOfWeek {
	Lunes,
	Martes,
	Miércoles,
	Jueves,
	Viernes,
	Sábado,
	Domingo
}

public class Time {
	// time_slot and day form primary key, we must be able to pick amongst all time combinatios (with a combo box for example)
	public TimeSlot time_slot { get; set; }  // mañana, tarde, noche, día completo (we should define the time slots from x to y time and show them in the interface)
	public DayOfWeek day { get; set; }  // lunes, martes, miércoles, jueves, viernes, sábado, domingo
	
	// FKs

	// instead of using the volunteer list below, we query the database for the volunteers that have this time preference when needed to avoid keeping a giant list of volunteers in memory
	//public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
}
