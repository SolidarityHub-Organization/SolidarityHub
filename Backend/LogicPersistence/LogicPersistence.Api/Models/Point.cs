using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public abstract class Point
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public DateTime created_at { get; set; } 
    public int time_id { get; set; } 
    public int location_id { get; set; }
}

public class PickupPoint : Point {}

public class MeetingPoint : Point {}