using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public abstract class PointBaseDto
{
    [Required]
    public string name { get; set; } = string.Empty;

    [Required]
    public string description { get; set; } = string.Empty;

    [Required]
    public DateTime created_at { get; set; } 

    [Required]
    public int time_id { get; set; } 

    [Required]
    public int location_id { get; set; }
}

#region Pickup Point DTOs
public class PickupPointCreateDto : PointBaseDto
{
    
}

public class PickupPointUpdateDto : PointBaseDto
{
    [Required]
    public int id { get; set; } 
}

public class PickupPointDisplayDto : PointBaseDto
{
    public int id { get; set; } // ID of the PickupPoint to display
}
#endregion
#region Meeting Point DTOs
public class MeetingPointCreateDto : PointBaseDto
{
    
}

public class MeetingPointUpdateDto : PointBaseDto
{
    [Required]
    public int id { get; set; } 
}

public class MeetingPointDisplayDto : PointBaseDto
{
    public int id { get; set; } // ID of the MeetingPoint to display
}
#endregion