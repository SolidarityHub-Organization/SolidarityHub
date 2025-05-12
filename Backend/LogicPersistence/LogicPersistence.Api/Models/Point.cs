using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public abstract class Point
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public DateTime created_at { get; set; } 

    // FKs
    public int time_id { get; set; } 
    public int location_id { get; set; }
    public int? admin_id { get; set; }


    // Navigation properties

    //public virtual Time Time { get; set; } = new Time();
    //public virtual Location Location { get; set; } = new Location();
    //public virtual Admin Admin { get; set; } = new Admin();
}

public class PickupPoint : Point
{    
    // Navigation properties

    //public virtual ICollection<PhysicalDonation> PhysicalDonations { get; set; } = new List<PhysicalDonation>();  // in intermediate table
}

public class MeetingPoint : Point
{
    // TODO: add number of attendees or attendees themselves here
}