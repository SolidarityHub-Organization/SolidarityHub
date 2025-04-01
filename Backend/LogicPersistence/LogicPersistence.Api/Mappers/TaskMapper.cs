namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class TaskMapper 
{
    public static Task ToTask(this TaskCreateDto taskCreateDto) 
    {
        return new Task {
            name = taskCreateDto.name,
            description = taskCreateDto.description,
            admin_id = taskCreateDto.admin_id ?? -1,
        };
    }

    public static Task ToTask(this TaskUpdateDto taskUpdateDto) 
    {
        return new Task {
            id = taskUpdateDto.id,
            name = taskUpdateDto.name,
            description = taskUpdateDto.description,
            admin_id = taskUpdateDto.admin_id ?? -1,
        };
    }

    public static TaskDisplayDto ToTaskDisplayDto(this Task task) 
    {
        return new TaskDisplayDto {
            id = task.id,
            name = task.name,
            description = task.description,
            admin_id = task.admin_id,
        };
    }
}