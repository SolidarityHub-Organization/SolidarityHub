namespace LogicPersistence.Api.Models;

// volunteers can have several prefered times
public class VolunteerTime {
	public int volunteer_id { get; set; }
	public int time_slot { get; set; }
    public int day { get; set; }
}