using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum TransportType {
	[Display(Name = "Otro")]
	Other = -1,
	[Display(Name = "Coche")]
	Car = 0,
	[Display(Name = "Bicicleta")]
	Bike = 1,
	[Display(Name = "A pie")]
	Foot = 2,
	[Display(Name = "Barco")]
	Boat = 3,
	[Display(Name = "Avión")]
	Plane = 4,
	[Display(Name = "Tren")]
	Train = 5
}

public class Route {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	// if an admin sets the route and it isn't auto genereated, they should set a hazard_level
	public HazardLevel hazard_level { get; set; }
	public TransportType transport_type { get; set; }

    // FKs
    public int? admin_id { get; set; }
    public int start_location_id { get; set; }
    public int end_location_id { get; set; }


    // Navigation properties

    //public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    //public virtual Location StartLocation { get; set; }
    //public virtual Location EndLocation { get; set; }
    //public virtual Admin admin { get; set; }
}
