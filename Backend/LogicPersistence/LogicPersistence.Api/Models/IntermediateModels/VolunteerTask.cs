namespace LogicPersistence.Api.Models;

public enum State {
	Asignado = 0,
	Pendiente = 1,
	Completado = 2,
	Cancelado = 3
}

// volunteers can sign up for tasks
public class VolunteerTask {
	public int volunteer_id { get; set; }
	public int task_id { get; set; }
	public State state { get; set; }
}