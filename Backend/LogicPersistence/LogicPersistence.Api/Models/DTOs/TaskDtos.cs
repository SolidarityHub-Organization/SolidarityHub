using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class TaskCreateDto {
    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public int? admin_id { get; set; }

    [Required]
    public int location_id { get; set; }

    [Required]
    public int[] volunteer_ids { get; set; } = [];
}

public class TaskUpdateDto {
    [Required]
    public int id { get; set; }

    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public int? admin_id { get; set; }

    [Required]
    public int location_id { get; set; }
}

public class TaskDisplayDto {
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public int? admin_id { get; set; }
    public int location_id { get; set; }
}