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
    
    public VictimMapMarkerDTO()
    {
        type = "victim";
    }
}

public class VolunteerMapMarkerDTO : MapMarkerDTO 
{
    public VolunteerMapMarkerDTO()
    {
        type = "volunteer";
    }
}

public class TaskMapMarkerDTO : MapMarkerDTO
{
    public string state { get; set; } = string.Empty;
    public IEnumerable<Volunteer> assigned_volunteers { get; set; } = new List<Volunteer>();

    public TaskMapMarkerDTO()
    {
        type = "task";
    }
}

public class BasePointMapMarkerDTO : MapMarkerDTO
{
    public PointTime? time { get; set; }
}

public class PickupPointMapMarkerDTO : BasePointMapMarkerDTO 
{     
    public IEnumerable<PhysicalDonation> physical_donation { get; set; } = new List<PhysicalDonation>();

    public PickupPointMapMarkerDTO()
    {
        type = "pickup_point";
    }
}

public class MeetingPointMapMarkerDTO : BasePointMapMarkerDTO 
{
    public MeetingPointMapMarkerDTO()
    {
        type = "meeting_point";
    }
}


public static class MapMarkerFactory
{
        public static async Task<T> CreateBaseMapMarker<T>(dynamic entity, Location location) where T : MapMarkerDTO, new()
        {
        var dto = new T
        {
            id = entity.id,
            name = entity.name
        };
            
        if (location != null)
        {
            dto.latitude = location.latitude;
            dto.longitude = location.longitude;
        }
            
        return dto;
    }
}
