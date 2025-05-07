using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;
public class MapMarkerDTO 
{
	public int id { get; set; }
    public string name { get; set; } = string.Empty;

    public string type { get; set; } = string.Empty;
    public double latitude { get; set; }
    public double longitude { get; set; }
}

public class VictimMapMarkerDTO : MapMarkerDTO 
{
    public string urgency_level { get; set; } = string.Empty;
}

public class VolunteerMapMarkerDTO : MapMarkerDTO {}

public class TaskMapMarkerDTO : MapMarkerDTO
{
    public string state { get; set; } = string.Empty;
    public ICollection<Volunteer> assigned_volunteers { get; set; } = new List<Volunteer>();
}