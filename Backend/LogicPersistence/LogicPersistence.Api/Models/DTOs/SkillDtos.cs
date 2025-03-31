using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class SkillCreateDto 
{
    [Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
    public SkillLevel level { get; set; }

    [Required]
    public int admin_id { get; set; }
}

public class SkillUpdateDto 
{
    [Required]
    public int id { get; set; }

    [MaxLength(50)]
    public string? name { get; set; }

    public SkillLevel? level { get; set; }

	public int admin_id { get; set; }
}

public class SkillDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public SkillLevel level { get; set; }
    public int admin_id { get; set; }
}
