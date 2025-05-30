using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class MapStrategyCreateDto<AffectedZoneWithPointsDTO> {

    [Required]
    [MaxLength(255)]
    public string description { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    public string Strategy { get; set; } = string.Empty;
}