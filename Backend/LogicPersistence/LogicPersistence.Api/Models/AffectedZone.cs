using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum HazardLevel {
	[Display(Name = "Desconocido")]
	Unknown = -1,
	// representa las zonas de riesgo
	[Display(Name = "Ninguno")]
	None = 0,
	[Display(Name = "Bajo")]
	Low = 1,
	[Display(Name = "Medio")]
	Medium = 2,
	[Display(Name = "Alto")]
	High = 3,
	[Display(Name = "Crítico")]
	Critical = 4
}

public class AffectedZone {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	public HazardLevel hazard_level { get; set; }

	// FKs
	public int admin_id { get; set; }


	// Navigation properties

    // 1 location with a radius or more than 3 connected locations can be a zone
    //public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    //public virtual Admin Admin { get; set; }
}
