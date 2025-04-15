using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class AffectedZoneCreateDto 
{
    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public HazardLevel hazard_level { get; set; }

    [Required]
    public int admin_id { get; set; }
}

public class AffectedZoneUpdateDto 
{
    [Required]
    public int id { get; set; }

    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public HazardLevel hazard_level { get; set; }

    [Required]
    public int admin_id { get; set; }
}

public class AffectedZoneDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public HazardLevel hazard_level { get; set; }
    public int admin_id { get; set; }
}

public class AffectedZoneWithPointsDTO : AffectedZoneDisplayDto
{
    public List<LocationDisplayDto> points { get; set; } = new List<LocationDisplayDto>();
}