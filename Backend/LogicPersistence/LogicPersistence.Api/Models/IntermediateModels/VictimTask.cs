namespace LogicPersistence.Api.Models;

// victims can be assigned to tasks
public class VictimTask {
	public int victim_id { get; set; }
	public int task_id { get; set; }
	public State state { get; set; }
}
