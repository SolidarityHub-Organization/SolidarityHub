namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class AdminMapper 
{
    public static Admin ToAdmin(this AdminCreateDto adminCreateDto) 
    {
        return new Admin {
            email = adminCreateDto.email,
            password = adminCreateDto.password,
            jurisdiction = adminCreateDto.jurisdiction,
            name = adminCreateDto.name,
            surname = adminCreateDto.surname,
            prefix = adminCreateDto.prefix,
            phone_number = adminCreateDto.phone_number,
            address = adminCreateDto.address,
            identification = adminCreateDto.identification
        };
    }

    public static Admin ToAdmin(this AdminUpdateDto adminUpdateDto) 
    {
        return new Admin {
            id = adminUpdateDto.id,
            email = adminUpdateDto.email,
            password = adminUpdateDto.password,
            jurisdiction = adminUpdateDto.jurisdiction,
            name = adminUpdateDto.name,
            surname = adminUpdateDto.surname,
            prefix = adminUpdateDto.prefix,
            phone_number = adminUpdateDto.phone_number,
            address = adminUpdateDto.address,
            identification = adminUpdateDto.identification
        };
    }

    public static AdminDisplayDto ToAdminDisplayDto(this Admin admin) 
    {
        return new AdminDisplayDto {
            id = admin.id,
            email = admin.email,
            jurisdiction = admin.jurisdiction,
            name = admin.name,
            surname = admin.surname,
            prefix = admin.prefix,
            phone_number = admin.phone_number,
            address = admin.address,
            identification = admin.identification
            // Password is intentionally omitted for security
        };
    }
}