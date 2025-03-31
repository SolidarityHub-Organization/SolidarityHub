using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class TaskCreateDto 
{
    [Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string description { get; set; } = string.Empty;

    // Only one of these should be provided to determine task type
    public int? admin_id { get; set; }
    public int? victim_id { get; set; }
}

public class TaskUpdateDto 
{
    [Required]
    public int id { get; set; }

    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? description { get; set; }

    public int? admin_id { get; set; }
    public int? victim_id { get; set; }
}

public class TaskDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public int? admin_id { get; set; }
    public int? victim_id { get; set; }
    // Type can be determined by which ID is not null
}