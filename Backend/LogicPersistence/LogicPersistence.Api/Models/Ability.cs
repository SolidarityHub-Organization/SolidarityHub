namespace LogicPersistence.Api.Models;

public abstract class User
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string level { get; set; } = string.Empty;
}