namespace LogicPersistence.Api.Models.Builders;

public class PhysicalDonationBuilder : DonationBuilder<PhysicalDonation>
{
    public new PhysicalDonationBuilder WithId(int id)
    {
        base.WithId(id);
        return this;
    }

    public new PhysicalDonationBuilder WithDonationDate(DateTime donationDate)
    {
        base.WithDonationDate(donationDate);
        return this;
    }

    public new PhysicalDonationBuilder WithVolunteerId(int? volunteerId)
    {
        base.WithVolunteerId(volunteerId);
        return this;
    }

    public new PhysicalDonationBuilder WithAdminId(int? adminId)
    {
        base.WithAdminId(adminId);
        return this;
    }

    public new PhysicalDonationBuilder WithVictimId(int? victimId)
    {
        base.WithVictimId(victimId);
        return this;
    }

    public PhysicalDonationBuilder WithItemName(string itemName)
    {
        donation.item_name = itemName;
        return this;
    }

    public PhysicalDonationBuilder WithDescription(string description)
    {
        donation.description = description;
        return this;
    }

    public PhysicalDonationBuilder WithQuantity(int quantity)
    {
        donation.quantity = quantity;
        return this;
    }

    public PhysicalDonationBuilder WithItemType(PhysicalDonationType itemType)
    {
        donation.item_type = itemType;
        return this;
    }
} 