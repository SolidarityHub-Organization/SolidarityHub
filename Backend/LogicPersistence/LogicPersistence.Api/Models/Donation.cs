namespace LogicPersistence.Api.Models;

public enum DonationType {
    Physical,
    Monetary
}

public enum PhysicalDonationType {
    Comida,
    Herramientas,
    Ropa,
    Medicamentos,
    Muebles,
    Otro
}

public enum Currency {
    USD,
    EUR,
    Otro
}

public enum PaymentStatus {
    Pendiente,
    Completado,
    Fallido,
    Reembolsado
}

public enum PaymentService {
    PayPal,
    Stripe,
    TransferenciaBancaria,
    TarjetaCredito,
    Otro
}

public class Donation {
    public int id { get; set; }
    public DateTime donation_date { get; set; }
    public required DonationType type { get; set; }

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
    public required string item_name { get; set; }
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