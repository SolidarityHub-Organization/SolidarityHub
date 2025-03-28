using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class PreferenceCreateDto 
{
    [Required]
    [MaxLength(30)]
    public string name {get; set;} = string.Empty;
}

public class PreferenceUpdateDto 
{
    public int id {get; set;}
    
    [Required]
    [MaxLength(30)]
    public string name {get; set;} = string.Empty;
}

public class PreferenceDisplayDto
{
    public int id {get; set;}
    public string name {get; set;} = string.Empty;
}