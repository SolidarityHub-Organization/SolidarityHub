namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

// Mappers transform data between DTOs and domain models.

public static class VolunteerMapper {
    public static Volunteer ToVolunteer(this VolunteerCreateDto volunteerCreateDto) {
        return new Volunteer {
            email = volunteerCreateDto.email,
            password = volunteerCreateDto.password,
            name = volunteerCreateDto.name,
            surname = volunteerCreateDto.surname,
            prefix = volunteerCreateDto.prefix,
            phone_number = volunteerCreateDto.phone_number,
            address = volunteerCreateDto.address,
            identification = volunteerCreateDto.identification,

            location_id = volunteerCreateDto.location_id
        };
    }

    public static Volunteer ToVolunteer(this VolunteerUpdateDto volunteerUpdateDto) {
        return new Volunteer {
            id = volunteerUpdateDto.id,
            email = volunteerUpdateDto.email,
            password = volunteerUpdateDto.password,
            name = volunteerUpdateDto.name,
            surname = volunteerUpdateDto.surname,
            prefix = volunteerUpdateDto.prefix,
            phone_number = volunteerUpdateDto.phone_number,
            address = volunteerUpdateDto.address,
            identification = volunteerUpdateDto.identification,

            location_id = volunteerUpdateDto.location_id
        };
    }

    public static VolunteerDisplayDto ToVolunteerDisplayDto(this Volunteer volunteer) {
        return new VolunteerDisplayDto {
            id = volunteer.id,
            email = volunteer.email,
            name = volunteer.name,
            surname = volunteer.surname,
            prefix = volunteer.prefix,
            phone_number = volunteer.phone_number,
            address = volunteer.address,
            identification = volunteer.identification,
            created_at = volunteer.created_at,
            // Password is intentionally omitted.

            location_id = volunteer.location_id
        };
    }
}
