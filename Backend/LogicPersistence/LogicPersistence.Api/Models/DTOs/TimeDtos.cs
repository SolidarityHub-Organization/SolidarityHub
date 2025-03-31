using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class TimeCreateDto 
{
    [Required]
    public TimeSlot time_slot { get; set; }

    [Required]
    public DayOfWeek day { get; set; }
}

public class TimeUpdateDto 
{
    [Required]
    public TimeSlot time_slot { get; set; }

    [Required]
    public DayOfWeek day { get; set; }
}

public class TimeDisplayDto 
{
    public TimeSlot time_slot { get; set; }
    public DayOfWeek day { get; set; }
}