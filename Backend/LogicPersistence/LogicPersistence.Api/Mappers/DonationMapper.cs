namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Models.Builders;

public static class DonationMapper 
{
    public static PhysicalDonation ToPhysicalDonation(this PhysicalDonationCreateDto donationCreateDto) 
    {
        return new PhysicalDonationBuilder()
            .WithItemName(donationCreateDto.item_name)
            .WithDescription(donationCreateDto.description)
            .WithQuantity(donationCreateDto.quantity)
            .WithItemType(donationCreateDto.item_type)
            .WithVolunteerId(donationCreateDto.volunteer_id)
            .WithAdminId(donationCreateDto.admin_id)
            .WithVictimId(donationCreateDto.victim_id)
            .WithDonationDate(donationCreateDto.donation_date)
            .Build();
    }

    public static PhysicalDonation ToPhysicalDonation(this PhysicalDonationUpdateDto donationUpdateDto) 
    {
        return new PhysicalDonationBuilder()
            .WithId(donationUpdateDto.id)
            .WithItemName(donationUpdateDto.item_name)
            .WithDescription(donationUpdateDto.description)
            .WithQuantity(donationUpdateDto.quantity)
            .WithItemType(donationUpdateDto.item_type)
            .WithVolunteerId(donationUpdateDto.volunteer_id)
            .WithAdminId(donationUpdateDto.admin_id)
            .WithVictimId(donationUpdateDto.victim_id)
            .WithDonationDate(donationUpdateDto.donation_date)
            .Build();
    }

    public static MonetaryDonation ToMonetaryDonation(this MonetaryDonationCreateDto donationCreateDto) 
    {
        return new MonetaryDonationBuilder()
            .WithAmount(donationCreateDto.amount)
            .WithCurrency(donationCreateDto.currency)
            .WithPaymentService(donationCreateDto.payment_service)
            .WithPaymentStatus(PaymentStatus.Pending)  // always starts as pending
            .WithVolunteerId(donationCreateDto.volunteer_id)
            .WithAdminId(donationCreateDto.admin_id)
            .WithVictimId(donationCreateDto.victim_id)
            .WithDonationDate(donationCreateDto.donation_date)
            .Build();
    }

    public static MonetaryDonation ToMonetaryDonation(this MonetaryDonationUpdateDto donationUpdateDto) 
    {
        return new MonetaryDonationBuilder()
            .WithId(donationUpdateDto.id)
            .WithAmount(donationUpdateDto.amount)
            .WithCurrency(donationUpdateDto.currency)
            .WithPaymentService(donationUpdateDto.payment_service)
            .WithPaymentStatus(donationUpdateDto.payment_status)
            .WithVolunteerId(donationUpdateDto.volunteer_id)
            .WithAdminId(donationUpdateDto.admin_id)
            .WithVictimId(donationUpdateDto.victim_id)
            .WithDonationDate(donationUpdateDto.donation_date)
            .Build();
    }

    public static PhysicalDonationDisplayDto ToPhysicalDonationDisplayDto(this PhysicalDonation donation, Volunteer? volunteer = null) 
    {
        return new PhysicalDonationDisplayDto {
            id = donation.id,
            item_name = donation.item_name,
            description = donation.description,
            quantity = donation.quantity,
            item_type = donation.item_type,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id,
            donation_date = donation.donation_date,
            volunteer_name = volunteer?.name,
            volunteer_surname = volunteer?.surname
        };
    }

    public static MonetaryDonationDisplayDto ToMonetaryDonationDisplayDto(this MonetaryDonation donation, Volunteer? volunteer = null) 
    {
        return new MonetaryDonationDisplayDto {
            id = donation.id,
            amount = donation.amount,
            currency = donation.currency,
            payment_service = donation.payment_service,
            payment_status = donation.payment_status,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id,
            donation_date = donation.donation_date,
            volunteer_name = volunteer?.name,
            volunteer_surname = volunteer?.surname
        };
    }
}