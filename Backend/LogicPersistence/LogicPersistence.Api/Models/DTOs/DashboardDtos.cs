namespace LogicPersistence.Api.Models.DTOs;

public class ActivityLogDto
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public double? amount { get; set; }
    public string type { get; set; } = string.Empty;
    public DateTime date { get; set; }
    public string? currency { get; set; }
}