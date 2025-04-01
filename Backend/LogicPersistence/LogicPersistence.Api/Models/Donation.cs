using System.ComponentModel.DataAnnotations;

namespace LogicPersistence.Api.Models;

public enum PhysicalDonationType {
    [Display(Name = "Otro")]
    Other,
    [Display(Name = "Comida")]
    Food,
    [Display(Name = "Herramientas")]
    Tools,
    [Display(Name = "Ropa")]
    Clothes,
    [Display(Name = "Medicamentos")]
    Medicine,
    [Display(Name = "Muebles")]
    Furniture
}

public enum Currency {
    [Display(Name = "Otro")]
    Other,
    [Display(Name = "Dólares")]
    USD,
    [Display(Name = "Euros")]
    EUR
}

public enum PaymentStatus {
    [Display(Name = "Pendiente")]
    Pending,
    [Display(Name = "Completado")]
    Completed,
    [Display(Name = "Fallido")]
    Failed,
    [Display(Name = "Reembolsado")]
    Refunded
}

public enum PaymentService {
    [Display(Name = "PayPal")]
    PayPal,
    [Display(Name = "Stripe")]
    Stripe,
    [Display(Name = "Transferencia Bancaria")]
    BankTransfer,
    [Display(Name = "Tarjeta de Crédito")]
    CreditCard,
    [Display(Name = "Otro")]
    Other
}

public class Donation {
    public int id { get; set; }
    public DateTime donation_date { get; set; }

    // FKs
    // donations can be done by volunteers or admins
    public int volunteer_id { get; set; }
    public int victim_id { get; set; }
    public int admin_id { get; set; }

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