using System;
using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class LoginDto {
	[Required]
	[EmailAddress]
	[MaxLength(255)]
	public string email { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string password { get; set; } = string.Empty;

}
