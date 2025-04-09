using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class RouteCreateDto 
{
    [Required]
    [MaxLength(255)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string description { get; set; } = string.Empty;

    [Required]
    public HazardLevel hazard_level { get; set; }
    // can be unknown

    [Required]
    public TransportType transport_type { get; set; }

    public int? admin_id { get; set; }

    [Required]
    public int start_location_id { get; set; }

    [Required]
    public int end_location_id { get; set; }
}

public class RouteUpdateDto 
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
    public TransportType transport_type { get; set; }

    [Required]
    public int start_location_id { get; set; }
    
    [Required]
    public int end_location_id { get; set; }

    public int? admin_id { get; set; }
}

public class RouteDisplayDto 
{
    public int id { get; set; }
    public string name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public HazardLevel hazard_level { get; set; }
    public TransportType transport_type { get; set; }
    public int? admin_id { get; set; }
    public int start_location_id { get; set; }
    public int end_location_id { get; set; }
}