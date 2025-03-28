using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class UserCreateDto
{
    [Required]
    [EmailAddress]
    [MaxLength(30)]
    public string email {get; set;} = string.Empty;

    [Required]
    [MinLength(8)]
    public string password {get; set;} = string.Empty;
}

public class UserUpdateDto
{
    public int id {get; set;}

    [Required]
    [EmailAddress]
    [MaxLength(30)]
    public string email {get; set;} = string.Empty;

    [Required]
    [MinLength(8)]
    public string password {get; set;} = string.Empty;
}

public class UserDisplayDto
{
    public int id {get; set;}
    public string email {get; set;} = string.Empty;
}