using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class SignupDto {

	[Required]
	[EmailAddress]
	[MaxLength(255)]
	public string email { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string password { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string name { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string surname { get; set; } = string.Empty;

	[Required]
	[Range(1, 99999)]
	public int prefix { get; set; }

	[Required]
	[Range(100000000, 99999999999)]
	public required string phone_number { get; set; }

	[Required]
	[MaxLength(255)]
	public string address { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string identification { get; set; } = string.Empty;

	public int? location_id { get; set; }

	public string role { get; set; } = string.Empty;
}
