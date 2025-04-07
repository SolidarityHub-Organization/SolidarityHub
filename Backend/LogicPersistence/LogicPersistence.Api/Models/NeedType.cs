namespace LogicPersistence.Api.Models;

public class NeedType {
	// a victim can set a task for themselves might be able to create a task through a need?
	public int id { get; set; }

	public string name { get; set; } = string.Empty;


    // FKs
	public int admin_id { get; set; }


	// Navigation properties

	//public virtual ICollection<Need> Needs { get; set; } = new List<Need>();
    //public virtual Admin Admin { get; set; }
}
