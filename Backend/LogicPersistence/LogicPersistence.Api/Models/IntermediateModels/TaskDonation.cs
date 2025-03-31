namespace LogicPersistence.Api.Models;

// tasks can have several donations
public class TaskDonation {
	public int task_id { get; set; }
	public int donation_id { get; set; }
}