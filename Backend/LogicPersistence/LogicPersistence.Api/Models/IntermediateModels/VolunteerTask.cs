namespace LogicPersistence.Api.Models;

public enum State {
	Assigned = 0,
	Pending = 1,
	Completed = 2,
	Cancelled = 3
}

// volunteers can sign up for tasks
public class VolunteerTask {
	public int volunteer_id { get; set; }
	public int task_id { get; set; }
	public State state { get; set; }
}