using System.Numerics;

namespace LogicPersistence.Api.Models;

public class Admin {
	public int id { get; set; }
	public string jurisdiction { get; set; } = string.Empty;
	public string email { get; set; } = string.Empty;
	public string password { get; set; } = string.Empty;
	public string name { get; set; } = string.Empty;
	public string surname { get; set; } = string.Empty;
	public int prefix { get; set; }
	public BigInteger phone_number { get; set; }
	public string address { get; set; } = string.Empty;
	public string identification { get; set; } = string.Empty;

	// FKs


	// Navigation properties

	//public virtual ICollection<AffectedZone> AffectedZones { get; set; } = new List<AffectedZone>();
	//public virtual ICollection<Route> Routes { get; set; } = new List<Route>();
	//public virtual ICollection<MonetaryDonation/PhysicalDonation> Donations { get; set; } = new List<MonetaryDonation/PhysicalDonation>();
	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
	//public virtual ICollection<Need> Needs { get; set; } = new List<Need>();
	//public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();
	//public virtual ICollection<Place> Places { get; set; } = new List<Place>();
	//public virtual ICollection<NeedType> NeedTypes { get; set; } = new List<NeedType>();
}
