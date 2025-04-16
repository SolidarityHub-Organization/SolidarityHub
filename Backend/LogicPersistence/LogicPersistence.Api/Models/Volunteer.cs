using LogicPersistence.Api.Logic;
using LogicPersistence.Api.Services;

using System.Numerics;

namespace LogicPersistence.Api.Models;

public class Volunteer : IUser{
	// this id is used for many to many relationships (as volunteer_id) as a connection
	public int id { get; set; }
	public string email { get; set; } = string.Empty;
	public string password { get; set; } = string.Empty;
	public string name { get; set; } = string.Empty;
	public string surname { get; set; } = string.Empty;
	public int prefix { get; set; }
	public string phone_number { get; set; }
	public string address { get; set; } = string.Empty;
	public string identification { get; set; } = string.Empty;

	// FKs
	// connections to other tables/entities that aren't many to many
	public int? location_id { get; set; }


	// Navigation properties

	// we don't use this navigation property to maintain consistency with not using the massive navigation property lists, we get time preference through another query instead, even if this one wouldn't occupy much memory
	//public virtual ICollection<VolunteerTime> VolunteerTimes { get; set; } = new List<VolunteerTime>();
	//public virtual ICollection<Skill> Skills { get; set; } = new List<Skill>();
	//public virtual Location Location { get; set; }
	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
	//public virtual ICollection<MonetaryDonation/PhysicalDonation> Donations { get; set; } = new List<MonetaryDonation/PhysicalDonation>();

	public async Task<IUser> Save(ISignupServices _signupServices) {
		return await _signupServices.CreateVolunteerAsync(this);
	}
}
