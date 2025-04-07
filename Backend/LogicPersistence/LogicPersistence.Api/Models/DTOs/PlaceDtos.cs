using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class PlaceCreateDto 
{
    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    public int admin_id { get; set; }
}

public class PlaceUpdateDto 
{
    [Required]
    public int id { get; set; }

    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    public int admin_id { get; set; }
}

public class PlaceDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public int admin_id { get; set; }
}