namespace LogicPersistence.Api.Models;

public class Task {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;

	public string description { get; set; } = string.Empty;

    public DateTime created_at { get; set; } 

	// should have time_id instead of start_date and end_date
	public DateTime start_date { get; set; }
	public DateTime? end_date { get; set; }
    

	// the type defines the importance of the task
	// admin_id != null (high importance)
	// admin_id == null (low importance)
	// this is only the case if volunteers are able to create tasks through needs

	//we connect to Time to tell when the task must be done

	//we connect to Location to tell where the task must be done

	//we connect to Skill to tell what skills are needed to do the task


	// FKs
	public int? admin_id { get; set; }
	public int location_id { get; set; }


	// Navigation properties
	//public Time? time_id { get; set; }	//TODO

	//public virtual ICollection<Need> Needs { get; set; } = new List<Need>();
    //public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();
    //public virtual Location Location { get; set; }
    //public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
    //public virtual ICollection<Donation> Donations { get; set; } = new List<Donation>();
    //public virtual Admin Admin { get; set; }
    //public virtual ICollection<TaskTime> TaskTimes { get; set; } = new List<TaskTime>();
}
