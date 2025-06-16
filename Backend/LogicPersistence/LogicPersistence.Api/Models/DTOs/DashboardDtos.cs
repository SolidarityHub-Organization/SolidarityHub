namespace LogicPersistence.Api.Models.DTOs;

public class ActivityLogDto {
    public int id { get; set; }
    public string type { get; set; } = string.Empty;
    public DateTime date { get; set; }

    public string information { get; set; } = string.Empty;
}