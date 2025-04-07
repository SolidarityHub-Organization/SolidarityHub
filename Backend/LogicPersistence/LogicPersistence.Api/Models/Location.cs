namespace LogicPersistence.Api.Models;

public class Location {
	public int id { get; set; }
	public double latitude { get; set; }
	public double longitude { get; set; }


	// FKs


	// Navigation properties

	// 0..1 to 0..1 relationship held by victim and volunteer, we could remove these columns from the location table, but they might be useful for queries
	// these for now serve as naviagtion properties essentially (they shouldn't be marked as FKs, but they are used to navigate the relationship)
	public int? victim_id { get; set; }
	public int? volunteer_id { get; set; }

	public virtual ICollection<Task> Tasks { get; set; } = [];
	public virtual ICollection<AffectedZone> AffectedZones { get; set; } = [];
	public virtual Victim? Victim { get; set; }
	public virtual Volunteer? Volunteer { get; set; }
}
