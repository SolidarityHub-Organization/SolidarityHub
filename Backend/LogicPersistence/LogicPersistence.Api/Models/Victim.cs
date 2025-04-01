namespace LogicPersistence.Api.Models;

public class Victim {
	public int id { get; set; }
	public string email { get; set; } = string.Empty;
	public string password { get; set; } = string.Empty;
	public string name { get; set; } = string.Empty;
	public string surname { get; set; } = string.Empty;
	public int prefix { get; set; }
	public int phone_number { get; set; }
	public string address { get; set; } = string.Empty;
	public string identification { get; set; } = string.Empty;

	// FKs
	public int location_id { get; set; }

	//public virtual ICollection<Need> Needs { get; set; } = new List<Need>();
	//public virtual Location Location { get; set; }
	//public virtual ICollection<Donation> Donations { get; set; } = new List<Donation>();
}
