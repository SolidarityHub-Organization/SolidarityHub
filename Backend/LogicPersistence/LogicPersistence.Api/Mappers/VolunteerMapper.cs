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
            volunteer_id = volunteerCreateDto.volunteer_id,
            time_preference_id = volunteerCreateDto.time_preference_id
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
            volunteer_id = volunteerUpdateDto.volunteer_id,
            time_preference_id = volunteerUpdateDto.time_preference_id
        };
    }

    public static VolunteerDisplayDto ToVolunteerDisplayDto(this Volunteer volunteer, TimePreference? timePreference = null) {
        return new VolunteerDisplayDto {
            id = volunteer.id,
            email = volunteer.email,
            name = volunteer.name,
            surname = volunteer.surname,
            prefix = volunteer.prefix,
            phone_number = volunteer.phone_number,
            address = volunteer.address,
            volunteer_id = volunteer.volunteer_id,
            time_preference_id = volunteer.time_preference_id ?? 0,
            time_slot = timePreference?.time_slot ?? default,
            day = timePreference?.day ?? string.Empty
        };
    }
}
