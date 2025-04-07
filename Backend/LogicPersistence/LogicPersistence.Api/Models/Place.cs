namespace LogicPersistence.Api.Models;

public class Place {
	public int id { get; set; }
	public string name { get; set; } = string.Empty; // e.g. "valencia", "madrid", "barcelona"

	// FKs
	public int admin_id { get; set; }


	// Navigation properties

	public virtual ICollection<Volunteer> Volunteers { get; set; } = [];
	public virtual ICollection<AffectedZone> AffectedZones { get; set; } = [];

	// admins can set places
	public virtual Admin Admin { get; set; } = new Admin();
}
