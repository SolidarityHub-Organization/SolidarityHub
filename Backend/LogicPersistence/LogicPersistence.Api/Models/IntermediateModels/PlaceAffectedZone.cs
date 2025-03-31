namespace LogicPersistence.Api.Models;

// places can have several affected zones
public class PlaceAffectedZone {
	public int place_id { get; set; }
	public int affected_zone_id { get; set; }
}