using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum TimeSlot {
	[Display(Name = "Desconocido")]
	Unknown = -1,
    [Display(Name = "Mañana (6:00 - 12:00)")]
    Morning = 0,
    [Display(Name = "Tarde (12:00 - 18:00)")]
    Afternoon = 1,
    [Display(Name = "Noche (18:00 - 00:00)")]
    Night = 2,
    [Display(Name = "Día Completo (24h)")]
    FullDay = 3,
    [Display(Name = "Madrugada (00:00 - 6:00)")]
    EarlyMorning = 4,
}

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
    public TimeSlot time_slot { get; set; }  // mañana, tarde, noche, día completo (we should define the time slots from x to y time and show them in the interface)
    public DayOfWeek day { get; set; }  // lunes, martes, miércoles, jueves, viernes, sábado, domingo
    
    // FKs

    // instead of using the volunteer list below, we query the database for the volunteers that have this time preference when needed to avoid keeping a giant list of volunteers in memory
    //public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
    //public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
}
