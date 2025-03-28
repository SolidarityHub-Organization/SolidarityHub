namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Mappers;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

// Mappers transform data between DTOs and domain models.

public static class PersonMapper {
    public static Person ToPerson(this PersonCreateDto personCreateDto) {
        return new Person {
            name = personCreateDto.name,
            email = personCreateDto.email
        };
    }

    public static Person ToPerson(this PersonUpdateDto personUpdateDto) {
        return new Person {
            id = personUpdateDto.id,
            name = personUpdateDto.name,
            email = personUpdateDto.email
        };
    }

    public static PersonDisplayDto ToPersonDisplayDto(this Person person) {
        return new PersonDisplayDto {
            id = person.id,
            name = person.name,
            email = person.email
        };
    }
}