using System;

namespace LogicPersistence.Api.Models.Builders;

public abstract class DonationBuilder<T> where T : Donation, new()
{
    protected T donation;

    public DonationBuilder()
    {
        donation = new T();
    }

    public DonationBuilder<T> WithId(int id)
    {
        donation.id = id;
        return this;
    }

    public DonationBuilder<T> WithDonationDate(DateTime donationDate)
    {
        donation.donation_date = donationDate;
        return this;
    }

    public DonationBuilder<T> WithVolunteerId(int? volunteerId)
    {
        donation.volunteer_id = volunteerId;
        return this;
    }

    public DonationBuilder<T> WithAdminId(int? adminId)
    {
        donation.admin_id = adminId;
        return this;
    }

    public DonationBuilder<T> WithVictimId(int? victimId)
    {
        donation.victim_id = victimId;
        return this;
    }

    public T Build()
    {
        return donation;
    }
} 