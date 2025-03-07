using System;
using System.ComponentModel.DataAnnotations;

namespace DapperPostgresDemo.Api.Models.DTOs;

public class PersonUpdateDto {
    public int Id {get; set;}

    [Required]
    [MaxLength(30)]
    public string Name {get; set;} = string.Empty;

    [Required]
    [EmailAddress]
    [MaxLength(30)]
    public string Email {get; set;} = string.Empty;
}