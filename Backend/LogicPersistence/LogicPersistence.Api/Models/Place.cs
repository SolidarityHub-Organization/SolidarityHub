namespace LogicPersistence.Api.Models;

public class Place {
	public int id { get; set; }
	public string name { get; set; } = string.Empty; // e.g. "valencia", "madrid", "barcelona"

	// FKs
	public int admin_id { get; set; }

    //public virtual ICollection<Volunteer> Volunteers { get; set; } = new List<Volunteer>();
    //public virtual ICollection<AffectedZone> AffectedZones { get; set; } = new List<AffectedZone>();
	
	// admins can set places
	//public virtual Admin Admin { get; set; } = new Admin();
}
