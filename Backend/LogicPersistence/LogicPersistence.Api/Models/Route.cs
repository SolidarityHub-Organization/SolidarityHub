namespace LogicPersistence.Api.Models;

public enum TransportType {
    Car = 1,
    Bike = 2,
    Foot = 3,
    Boat = 4,
    Plane = 5,
    Train = 6
}

public class Route {
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    // if an admin sets the route and it isn't auto genereated, they should set a hazard_level
    public HazardLevel hazard_level { get; set; }
    public required TransportType transport_type { get; set; }

    // FKs
    public int admin_id { get; set; }
    public int start_location_id { get; set; }
    public int end_location_id { get; set; }

    //public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    //public virtual Location StartLocation { get; set; }
    //public virtual Location EndLocation { get; set; }
    //public virtual Admin admin { get; set; }
}