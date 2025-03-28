using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class SkillCreateDto {
	[Required]
	[MaxLength(50)]
	public string name { get; set; } = string.Empty;

	[Required]
	[Range(0, 2)]
	public int level { get; set; }
}

public class SkillUpdateDto {
	public int id { get; set; }

	[Required]
	[MaxLength(50)]
	public string name { get; set; } = string.Empty;

	[Required]
	[Range(0, 2)]
	public int level { get; set; }
}

public class SkillDisplayDto {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string level { get; set; } = string.Empty;
}
