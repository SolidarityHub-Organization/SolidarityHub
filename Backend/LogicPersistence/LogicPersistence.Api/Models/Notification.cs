namespace LogicPersistence.Api.Models;

public class Notification {
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public int? volunteer_id { get; set; }
    public int? victim_id { get; set; }
    public DateTime created_at { get; set; }
}
