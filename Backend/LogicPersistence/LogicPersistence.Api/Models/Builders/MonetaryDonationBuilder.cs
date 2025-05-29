namespace LogicPersistence.Api.Models.Builders;

public class MonetaryDonationBuilder : DonationBuilder<MonetaryDonation>
{
    public new MonetaryDonationBuilder WithId(int id)
    {
        base.WithId(id);
        return this;
    }

    public new MonetaryDonationBuilder WithDonationDate(DateTime donationDate)
    {
        base.WithDonationDate(donationDate);
        return this;
    }

    public new MonetaryDonationBuilder WithVolunteerId(int? volunteerId)
    {
        base.WithVolunteerId(volunteerId);
        return this;
    }

    public new MonetaryDonationBuilder WithAdminId(int? adminId)
    {
        base.WithAdminId(adminId);
        return this;
    }

    public new MonetaryDonationBuilder WithVictimId(int? victimId)
    {
        base.WithVictimId(victimId);
        return this;
    }

    public MonetaryDonationBuilder WithAmount(double amount)
    {
        donation.amount = amount;
        return this;
    }

    public MonetaryDonationBuilder WithCurrency(Currency currency)
    {
        donation.currency = currency;
        return this;
    }

    public MonetaryDonationBuilder WithPaymentStatus(PaymentStatus paymentStatus)
    {
        donation.payment_status = paymentStatus;
        return this;
    }

    public MonetaryDonationBuilder WithTransactionId(string transactionId)
    {
        donation.transaction_id = transactionId;
        return this;
    }

    public MonetaryDonationBuilder WithPaymentService(PaymentService paymentService)
    {
        donation.payment_service = paymentService;
        return this;
    }
} 