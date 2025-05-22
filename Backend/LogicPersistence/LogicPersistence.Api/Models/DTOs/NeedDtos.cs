using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class NeedCreateDto {
    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public UrgencyLevel urgencyLevel { get; set; } = UrgencyLevel.Unknown;

    public string status { get; set; } = "InProgress";

    public int? victim_id { get; set; }

    public int? admin_id { get; set; }

    public int? need_type_id { get; set; }
}

public class NeedUpdateDto {
    [Required]
    public int id { get; set; }

    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public UrgencyLevel urgencyLevel { get; set; }

    public string? status { get; set; }

    public int? victim_id { get; set; }

    public int? admin_id { get; set; }
    public int? need_type_id { get; set; }
}

public class NeedDisplayDto {
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public UrgencyLevel urgencyLevel { get; set; }
    public string? status { get; set; }
    public int? victim_id { get; set; }
    public int? admin_id { get; set; }
    public DateTime created_at { get; set; }
    public int? need_type_id { get; set; }
}
