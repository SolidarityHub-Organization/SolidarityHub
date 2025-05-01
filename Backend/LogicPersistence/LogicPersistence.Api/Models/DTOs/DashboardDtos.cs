namespace LogicPersistence.Api.Models.DTOs;

public class RecentActivityDto
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public decimal? amount { get; set; }
    public string type { get; set; } = string.Empty;
    public DateTime date { get; set; }

    public String currency { get; set; } = string.Empty;
}