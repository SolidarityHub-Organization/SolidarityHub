namespace LogicPersistence.Api.Models;

// needs can have several tasks necessary to complete said need
public class NeedTask {
	public int need_id { get; set; }
	public int task_id { get; set; }
}