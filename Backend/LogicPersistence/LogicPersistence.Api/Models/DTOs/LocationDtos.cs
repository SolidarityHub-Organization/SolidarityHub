using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class LocationCreateDto 
{
    [Required]
    [Range(-90, 90)]
    public double latitude { get; set; }

    [Required]
    [Range(-180, 180)]
    public double longitude { get; set; }

    // Only one of these should be provided
    public int? victim_id { get; set; }
    public int? volunteer_id { get; set; }
}

public class LocationUpdateDto 
{
    [Required]
    [Range(-90, 90)]
    public double latitude { get; set; }

    [Required]
    [Range(-180, 180)]
    public double longitude { get; set; }

    public int? victim_id { get; set; }
    public int? volunteer_id { get; set; }
}

public class LocationDisplayDto 
{
    public double latitude { get; set; }
    public double longitude { get; set; }
    public int? victim_id { get; set; }
    public int? volunteer_id { get; set; }
}