namespace LogicPersistence.Api.Models;

public abstract class User
{
    public int id { get; set; }
    public string email { get; set; } = string.Empty;
    public string password { get; set; } = string.Empty;
}