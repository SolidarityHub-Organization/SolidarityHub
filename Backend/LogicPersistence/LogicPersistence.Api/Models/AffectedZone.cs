namespace LogicPersistence.Api.Models;

public enum HazardLevel {
    Descinocido = -1,
    Bajo = 0,
    Medio = 1,
    Alto = 2,
    Critico = 3
}

public class AffectedZone {
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public required HazardLevel hazard_level { get; set; }

    // FKs
    public int admin_id { get; set; }

    // 1 location with a radius or more than 3 connected locations can be a zone
    //public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
    //public virtual Admin Admin { get; set; }
}