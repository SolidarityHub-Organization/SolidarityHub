using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class NeedCreateDto {
	[Required]
	[MaxLength(50)]
	public string name { get; set; } = string.Empty;

	[Required]
	[MaxLength(500)]
	public string description { get; set; } = string.Empty;

	[Required]
	[Range(0, 3)]
	public int urgencyLevel { get; set; } //aqui se muestra como int

}

public class NeedUpdateDto {
	public int id { get; set; }

	[Required]
	[MaxLength(50)]
	public string name { get; set; } = string.Empty;

	[Required]
	[MaxLength(500)]
	public string description { get; set; } = string.Empty;

	[Required]
	[Range(0, 3)]
	public int urgencyLevel { get; set; } //aqui se muestra como int
}

public class NeedDisplayDto {
	public int id { get; set; }
	public string name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	public string urgencyLevel { get; set; } = string.Empty; //aqui se muestra como string
}
