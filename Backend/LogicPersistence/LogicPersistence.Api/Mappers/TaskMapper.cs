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
            admin_id = taskCreateDto.admin_id,
            location_id = taskCreateDto.location_id,
            start_date = taskCreateDto.start_date,
            end_date = taskCreateDto.end_date
        };
    }

    public static Task ToTask(this TaskUpdateDto taskUpdateDto) 
    {
        return new Task {
            id = taskUpdateDto.id,
            name = taskUpdateDto.name,
            description = taskUpdateDto.description,
            admin_id = taskUpdateDto.admin_id,
            location_id = taskUpdateDto.location_id,
            start_date = taskUpdateDto.start_date,
            end_date = taskUpdateDto.end_date
        };
    }

    public static TaskDisplayDto ToTaskDisplayDto(this Task task) 
    {
        return new TaskDisplayDto {
            id = task.id,
            name = task.name,
            description = task.description,
            admin_id = task.admin_id,
            location_id = task.location_id,
            created_at = task.created_at,
            start_date = task.start_date,
            end_date = task.end_date
        };
    }
}