using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class PersonCreateDto 
{
    [Required]
    [MaxLength(30)]
    public string name {get; set;} = string.Empty;
}

public class PersonUpdateDto 
{
    public int id {get; set;}
    
    [Required]
    [MaxLength(30)]
    public string name {get; set;} = string.Empty;
}

public class PersonDisplayDto
{
    public int id {get; set;}
    public string name {get; set;} = string.Empty;
}