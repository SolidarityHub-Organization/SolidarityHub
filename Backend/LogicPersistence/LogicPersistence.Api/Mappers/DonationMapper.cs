namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class DonationMapper 
{
    public static PhysicalDonation ToPhysicalDonation(this PhysicalDonationCreateDto donationCreateDto) 
    {
        return new PhysicalDonation {
            item_name = donationCreateDto.item_name,
            description = donationCreateDto.description,
            quantity = donationCreateDto.quantity,
            item_type = donationCreateDto.item_type,
            volunteer_id = donationCreateDto.volunteer_id,
            admin_id = donationCreateDto.admin_id,
            victim_id = donationCreateDto.victim_id,
            donation_date = donationCreateDto.donation_date
        };
    }

    public static PhysicalDonation ToPhysicalDonation(this PhysicalDonationUpdateDto donationUpdateDto) 
    {
        return new PhysicalDonation {
            id = donationUpdateDto.id,
            item_name = donationUpdateDto.item_name,
            description = donationUpdateDto.description,
            quantity = donationUpdateDto.quantity,
            item_type = donationUpdateDto.item_type,
            volunteer_id = donationUpdateDto.volunteer_id,
            admin_id = donationUpdateDto.admin_id,
            victim_id = donationUpdateDto.victim_id,
            donation_date = donationUpdateDto.donation_date
        };
    }

    public static MonetaryDonation ToMonetaryDonation(this MonetaryDonationCreateDto donationCreateDto) 
    {
        return new MonetaryDonation {
            amount = donationCreateDto.amount,
            currency = donationCreateDto.currency,
            payment_service = donationCreateDto.payment_service,
            payment_status = PaymentStatus.Pending,  // always starts as pending
            volunteer_id = donationCreateDto.volunteer_id,
            admin_id = donationCreateDto.admin_id,
            victim_id = donationCreateDto.victim_id,
            donation_date = donationCreateDto.donation_date
        };
    }

    public static MonetaryDonation ToMonetaryDonation(this MonetaryDonationUpdateDto donationUpdateDto) 
    {
        return new MonetaryDonation {
            id = donationUpdateDto.id,
            amount = donationUpdateDto.amount,
            currency = donationUpdateDto.currency,
            payment_service = donationUpdateDto.payment_service,
            payment_status = donationUpdateDto.payment_status,
            volunteer_id = donationUpdateDto.volunteer_id,
            admin_id = donationUpdateDto.admin_id,
            victim_id = donationUpdateDto.victim_id,
            donation_date = donationUpdateDto.donation_date
        };
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