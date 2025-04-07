using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class NeedTypeCreateDto
{
    [Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
    public int admin_id { get; set; }
}

public class NeedTypeUpdateDto
{
    [Required]
    public int id { get; set; }

	[Required]
    [MaxLength(50)]
    public string name { get; set; } = string.Empty;

    [Required]
	public int admin_id { get; set; }
}