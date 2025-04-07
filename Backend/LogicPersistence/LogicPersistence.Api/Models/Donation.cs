using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum PhysicalDonationType {
	[Display(Name = "Otro")]
	Other = -1,
	[Display(Name = "Comida")]
	Food = 0,
	[Display(Name = "Herramientas")]
	Tools = 1,
	[Display(Name = "Ropa")]
	Clothes = 2,
	[Display(Name = "Medicamentos")]
	Medicine = 3,
	[Display(Name = "Muebles")]
	Furniture = 4
}

public enum Currency {
	[Display(Name = "Otro")]
	Other = -1,
	[Display(Name = "Dólares")]
	USD = 0,
	[Display(Name = "Euros")]
	EUR = 1
}

public enum PaymentStatus {
	[Display(Name = "Pendiente")]
	Pending = 0,
	[Display(Name = "Completado")]
	Completed = 1,
	[Display(Name = "Fallido")]
	Failed = 2,
	[Display(Name = "Reembolsado")]
	Refunded = 3
}

public enum PaymentService {
	[Display(Name = "Otro")]
	Other = -1,
	[Display(Name = "PayPal")]
	PayPal = 0,
	[Display(Name = "Transferencia Bancaria")]
	BankTransfer = 1,
	[Display(Name = "Tarjeta de Crédito")]
	CreditCard = 2
}

public abstract class Donation {
	public int id { get; set; }
	public DateTime donation_date { get; set; }


	// FKs
	// donations can be done by volunteers or admins
	public int? volunteer_id { get; set; }
	public int? admin_id { get; set; }

	public int? victim_id { get; set; }


	// Navigation properties

	//public virtual Volunteer Volunteer { get; set; }
	//public virtual Victim Victim { get; set; }
	//public virtual Admin Admin { get; set; }
	//public virtual ICollection<Task> Tasks { get; set; } = new List<Task>();
}

public class PhysicalDonation : Donation {
	public string item_name { get; set; } = string.Empty;
	public string description { get; set; } = string.Empty;
	public int quantity { get; set; }
	public PhysicalDonationType item_type { get; set; }
}

public class MonetaryDonation : Donation {
	public decimal amount { get; set; }
	public Currency currency { get; set; }
	public PaymentStatus payment_status { get; set; }
	public string transaction_id { get; set; } = string.Empty;
	public PaymentService payment_service { get; set; }
}
