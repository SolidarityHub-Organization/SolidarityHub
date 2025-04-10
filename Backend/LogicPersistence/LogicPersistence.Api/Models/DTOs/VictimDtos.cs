using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class VictimCreateDto {
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
	public int phone_number { get; set; }

	[Required]
	[MaxLength(255)]
	public string address { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string identification { get; set; } = string.Empty;

	public int? location_id { get; set; }
}

public class VictimUpdateDto {
	[Required]
	public int id { get; set; }

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
	public int phone_number { get; set; }

	[Required]
	[MaxLength(255)]
	public string address { get; set; } = string.Empty;

	[Required]
	[MaxLength(255)]
	public string identification { get; set; } = string.Empty;

	public int? location_id { get; set; }
}

public class VictimDisplayDto {
	// password is not included in DisplayDto for security
	public int id { get; set; }
	public string email { get; set; } = string.Empty;
	public string name { get; set; } = string.Empty;
	public string surname { get; set; } = string.Empty;
	public int prefix { get; set; }
	public int phone_number { get; set; }
	public string address { get; set; } = string.Empty;
	public string identification { get; set; } = string.Empty;

	public int? location_id { get; set; }
}
