using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum State {
	[Display(Name = "Desconocido")]
	Unknown = -1,
	[Display(Name = "Asignado")]
	Assigned = 0,
	[Display(Name = "Pendiente")]
	Pending = 1,
	[Display(Name = "Completado")]
	Completed = 2,
	[Display(Name = "Cancelado")]
	Cancelled = 3
}

// volunteers can sign up for tasks
public class VolunteerTask {
	public int volunteer_id { get; set; }
	public int task_id { get; set; }
	public State state { get; set; }
}