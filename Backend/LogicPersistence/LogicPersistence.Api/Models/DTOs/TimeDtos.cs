using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public abstract class TimeBaseDto
{
    [Required]
    public TimeOnly start_time { get; set; }

    [Required]
    public TimeOnly end_time { get; set; }
}

public class TaskTimeCreateDto : TimeBaseDto 
{
    [Required]
    public DateOnly date { get; set; }

    [Required]
    public int task_id { get; set; }
}

public class TaskTimeUpdateDto : TimeBaseDto 
{
    [Required]
    public int id { get; set; }

    [Required]
    public DateOnly date { get; set; }

    [Required]
    public int task_id { get; set; }
}

public class TaskTimeDisplayDto : TimeBaseDto
{
    public int id { get; set; }
    public DateOnly date { get; set; }
    public int task_id { get; set; }
}

public class VolunteerTimeCreateDto : TimeBaseDto
{
    [Required]
    public DayOfWeek day { get; set; }

    [Required]
    public int volunteer_id { get; set; }
}

public class VolunteerTimeUpdateDto : TimeBaseDto
{
    [Required]
    public int id { get; set; }

    [Required]
    public DayOfWeek day { get; set; }

    [Required]
    public int volunteer_id { get; set; }
}

public class VolunteerTimeDisplayDto : TimeBaseDto
{
    public int id { get; set; }
    public DayOfWeek day { get; set; }
    public int volunteer_id { get; set; }
}

#region PointTime DTOs
public class PointTimeCreateDto : TimeBaseDto
{
    [Required]
    public DateOnly start_date { get; set; }
    
    public DateOnly? end_date { get; set; }
    
    [Required]
    public int point_id { get; set; }
}

public class PointTimeUpdateDto : TimeBaseDto
{
    [Required]
    public int id { get; set; }
    
    [Required]
    public DateOnly start_date { get; set; }
    
    public DateOnly? end_date { get; set; }
    
    [Required]
    public int point_id { get; set; }
}

public class PointTimeDisplayDto : TimeBaseDto
{
    public int id { get; set; }
    public DateOnly start_date { get; set; }
    public DateOnly? end_date { get; set; }
    public int point_id { get; set; }
}
#endregion