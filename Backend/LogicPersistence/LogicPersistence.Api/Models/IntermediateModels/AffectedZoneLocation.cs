namespace LogicPersistence.Api.Models;

// several locations can make up a zone or more
public class AffectedZoneLocation {
	public int location_id { get; set; }
	public int affected_zone_id { get; set; }
}