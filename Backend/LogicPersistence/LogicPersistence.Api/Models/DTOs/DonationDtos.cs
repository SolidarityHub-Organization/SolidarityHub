using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models.DTOs;

public class PhysicalDonationCreateDto 
{
    [Required]
    [MaxLength(50)]
    public string item_name { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string description { get; set; } = string.Empty;

    [Required]
    [Range(1, int.MaxValue)]
    public int quantity { get; set; }

    [Required]
    public PhysicalDonationType item_type { get; set; }

    // One of these must be set to identify the donor
    public int? volunteer_id { get; set; }
    public int? admin_id { get; set; }
    public int? victim_id { get; set; }
}

public class MonetaryDonationCreateDto 
{
    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal amount { get; set; }

    [Required]
    public Currency currency { get; set; }

    [Required]
    public PaymentService payment_service { get; set; }

    // One of these must be set to identify the donor
    public int? volunteer_id { get; set; }
    public int? admin_id { get; set; }
    public int? victim_id { get; set; }
}

public class PhysicalDonationUpdateDto 
{
    [Required]
    public int id { get; set; }

    [Required]
    [MaxLength(50)]
    public string item_name { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string description { get; set; } = string.Empty;
    
    [Required]
    [Range(1, int.MaxValue)]
    public int quantity { get; set; }

    [Required]
    public PhysicalDonationType item_type { get; set; }

    // One of these must be set to identify the donor
    [Required]
    public int? volunteer_id { get; set; }
    [Required]
    public int? admin_id { get; set; }


    [Required]
    public int? victim_id { get; set; }
}

public class MonetaryDonationUpdateDto 
{
    [Required]
    public int id { get; set; }

    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal amount { get; set; }

    [Required]
    public Currency currency { get; set; }
    
    [Required]
    public PaymentService payment_service { get; set; }
    
    [Required]
    public PaymentStatus payment_status { get; set; }

    // One of these must be set to identify the donor
    [Required]
    public int? volunteer_id { get; set; }
    [Required]
    public int? admin_id { get; set; }


    [Required]
    public int? victim_id { get; set; }
}

public class PhysicalDonationDisplayDto 
{
    public int id { get; set; }
    public DateTime donation_date { get; set; }
    public int? volunteer_id { get; set; }
    public int? admin_id { get; set; }
    public int victim_id { get; set; }
    
    public string item_name { get; set; } = string.Empty;
    public string description { get; set; } = string.Empty;
    public int quantity { get; set; }
    public PhysicalDonationType item_type { get; set; }
}

public class MonetaryDonationDisplayDto 
{
    public int id { get; set; }
    public DateTime donation_date { get; set; }
    public int? volunteer_id { get; set; }
    public int? admin_id { get; set; }
    public int victim_id { get; set; }
    
    public decimal amount { get; set; }
    public Currency currency { get; set; }
    public PaymentStatus payment_status { get; set; }
    public PaymentService payment_service { get; set; }
}