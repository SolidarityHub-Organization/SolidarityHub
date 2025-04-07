using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class AdminCreateDto 
{
    [Required]
    [EmailAddress]
    [MaxLength(50)]
    public string email { get; set; } = string.Empty;

    [Required]
    [MaxLength(128)]
    public string password { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string jurisdiction { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string surname { get; set; } = string.Empty;

    [Required]
    [Range(1, 99999)]
    public int prefix { get; set; }

    [Required]
    [Range(100000000, 99999999999)]
    public int phone_number { get; set; }

    [Required]
    [MaxLength(100)]
    public string address { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string identification { get; set; } = string.Empty;
}

public class AdminUpdateDto 
{
   [Required]
    public int id { get; set; }

	[Required]
    [EmailAddress]
    [MaxLength(50)]
    public string email { get; set; } = string.Empty;

	[Required]
    [MaxLength(128)]
    public string password { get; set; } = string.Empty;

	[Required]
    [MaxLength(50)]
    public string jurisdiction { get; set; } = string.Empty;

	[Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

	[Required]
    [MaxLength(50)]
    public string surname { get; set; } = string.Empty;

	[Required]
    [Range(1, 99999)]
    public int prefix { get; set; }

	[Required]
    [Range(100000000, 99999999999)]
    public int phone_number { get; set; }

	[Required]
    [MaxLength(100)]
    public string address { get; set; } = string.Empty;

	[Required]
    [MaxLength(20)]
    public string identification { get; set; } = string.Empty;
}

public class AdminDisplayDto 
{
    // password is not included in DisplayDto for security
    public int id { get; set; }
    public string email { get; set; } = string.Empty;
    public string jurisdiction { get; set; } = string.Empty;
    public string name { get; set; } = string.Empty;
    public string surname { get; set; } = string.Empty;
    public int prefix { get; set; }
    public int phone_number { get; set; }
    public string address { get; set; } = string.Empty;
    public string identification { get; set; } = string.Empty;
}
