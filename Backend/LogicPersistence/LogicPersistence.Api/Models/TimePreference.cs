namespace LogicPersistence.Api.Models;

public enum TimeSlot {
	Mañana,
	Tarde,
	Noche,
	DiaCompleto
}

public class TimePreference {
	public int id { get; set; }
	public TimeSlot time_slot { get; set; }  // mañana, tarde, noche, día completo (we should define the time slots from x to y time and show them in the interface)
	public string day { get; set; } = string.Empty; // lunes, martes, miércoles, jueves, viernes, sábado, domingo
}
