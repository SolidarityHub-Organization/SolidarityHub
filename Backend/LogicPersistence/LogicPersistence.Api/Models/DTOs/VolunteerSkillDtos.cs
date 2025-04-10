using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class VolunteerSkillCreateDto 
{
    [Required]
    public int volunteer_id { get; set; }
    [Required]
    public int skill_id { get; set; }
}

public class VolunteerSkillUpdateDto 
{
    [Required]
    public int volunteer_id { get; set; }
    [Required]
    public int skill_id { get; set; }
}

public class VolunteerSkillDisplayDto 
{
    [Required]
    public int volunteer_id { get; set; }
    [Required]
    public int skill_id { get; set; }
}
