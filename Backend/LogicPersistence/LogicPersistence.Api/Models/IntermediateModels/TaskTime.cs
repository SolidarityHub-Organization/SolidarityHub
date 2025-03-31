namespace LogicPersistence.Api.Models;

// tasks can have several times
public class TaskTime {
	public int task_id { get; set; }
	public int time_slot { get; set; }
    public int day { get; set; }
}