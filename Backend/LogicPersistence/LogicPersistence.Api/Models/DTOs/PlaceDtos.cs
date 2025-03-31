using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class PlaceCreateDto 
{
    [Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
    public int admin_id { get; set; }
}

public class PlaceUpdateDto 
{
    [Required]
    public int id { get; set; }

    [MaxLength(50)]
    public string? name { get; set; }
}

public class PlaceDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public int admin_id { get; set; }
}