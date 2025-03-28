namespace LogicPersistence.Api.Models;

public enum UrgencyLevel
{
    Low,
    Medium,
    High,
    Critical
}

public class Need
{
    public int id {get; set;}

    public string name {get; set;}

    public string description {get; set;}

    public UrgencyLevel urgencyLevel {get; set;}
}