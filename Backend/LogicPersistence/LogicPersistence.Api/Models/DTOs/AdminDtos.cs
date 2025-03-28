using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class AdminCreateDto {
	[Required]
	[MaxLength(50)]
	public string jurisdiction { get; set; } = string.Empty;
}

public class AdminUpdateDto {
	public int id { get; set; }

	[Required]
	[MaxLength(50)]
	public string jurisdiction { get; set; } = string.Empty;
}

public class AdminDisplayDto {
	public int id { get; set; }
	public string jurisdiction { get; set; } = string.Empty;
}
