namespace DapperPostgresDemo.Api.Mappers;

using DapperPostgresDemo.Api.Mappers;
using DapperPostgresDemo.Api.Models;
using DapperPostgresDemo.Api.Models.DTOs;

public static class PersonMapper {
    public static Person ToPerson(this PersonCreateDto personCreateDto) {
        return new Person {
            Name = personCreateDto.Name,
            Email = personCreateDto.Email
        };
    }

    public static Person ToPerson(this PersonUpdateDto personUpdateDto) {
        return new Person {
            Id = personUpdateDto.Id,
            Name = personUpdateDto.Name,
            Email = personUpdateDto.Email
        };
    }

    public static PersonDisplayDto ToPersonDisplayDto(this Person person) {
        return new PersonDisplayDto {
            Id = person.Id,
            Name = person.Name,
            Email = person.Email
        };
    }
}