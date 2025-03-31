namespace LogicPersistence.Api.Models;

public class Location {
	public double latitude { get; set; }
    public double longitude { get; set; }

    // FKs
    public int victim_id { get; set; }
    public int volunteer_id { get; set; }

    //public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
    //public virtual ICollection<AffectedZone> AffectedZones { get; set; } = new List<AffectedZone>();
    //public virtual Victim Victim { get; set; }
    //public virtual Volunteer Volunteer { get; set; }
}