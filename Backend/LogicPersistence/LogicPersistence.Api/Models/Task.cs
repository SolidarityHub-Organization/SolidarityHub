namespace LogicPersistence.Api.Models;

/*
public enum TaskType {
	Victim,
    Admin
    //,Volunteer
}
*/

public class Task {
	public int id { get; set; }

	public required string description { get; set; }

    // the type defines the importance of the task
    // victim task (low importance)
    // admin task (high importance)
    //public TaskType type { get; set; }

    //we connect to Time to tell when the task must be done

    //we connect to Location to tell where the task must be done

    //we connect to Skill to tell what skills are needed to do the task

    // FKs
    // only one of the admin/victim ids must not be null to set the type of the task
    public int admin_id { get; set; }
    public int victim_id { get; set; }

    //public virtual ICollection<Need> Needs { get; set; } = new List<Need>();
    //public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();
    //public virtual Location Location { get; set; }
    //public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();

    // a victim can set a task for themselves
    //public virtual Victim Victim { get; set; }

    //public virtual ICollection<Donation> Donations { get; set; } = new List<Donation>();
    //public virtual Admin Admin { get; set; }
    //public virtual ICollection<Time> Times { get; set; } = new List<Time>();
}
