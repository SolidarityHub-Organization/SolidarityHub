using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

namespace LogicPersistence.Api.Mappers;

public static class TimeMapper 
{
    public static TaskTime ToTaskTime(this TaskTimeCreateDto taskTimeCreateDto)
    {
        return new TaskTime {
            start_time = taskTimeCreateDto.start_time,
            end_time = taskTimeCreateDto.end_time,
            date = taskTimeCreateDto.date,
            task_id = taskTimeCreateDto.task_id
        };
    }

    public static TaskTimeDisplayDto ToTaskTimeDisplayDto(this TaskTime taskTime)
    {
        return new TaskTimeDisplayDto {
            id = taskTime.id,
            start_time = taskTime.start_time,
            end_time = taskTime.end_time,
            date = taskTime.date,
            task_id = taskTime.task_id
        };
    }

    public static VolunteerTime ToVolunteerTime(this VolunteerTimeCreateDto volunteerTimeCreateDto)
    {
        return new VolunteerTime {
            start_time = volunteerTimeCreateDto.start_time,
            end_time = volunteerTimeCreateDto.end_time,
            day = volunteerTimeCreateDto.day,
            volunteer_id = volunteerTimeCreateDto.volunteer_id
        };
    }

    public static VolunteerTimeDisplayDto ToVolunteerTimeDisplayDto(this VolunteerTime volunteerTime)
    {
        return new VolunteerTimeDisplayDto {
            id = volunteerTime.id,
            start_time = volunteerTime.start_time,
            end_time = volunteerTime.end_time,
            day = volunteerTime.day,
            volunteer_id = volunteerTime.volunteer_id
        };
    }

    public static PointTime ToPointTime(this PointTimeCreateDto pointTimeCreateDto)
    {
        return new PointTime {
            start_time = pointTimeCreateDto.start_time,
            end_time = pointTimeCreateDto.end_time,
            start_date = pointTimeCreateDto.start_date,
            end_date = pointTimeCreateDto.end_date,
            point_id = pointTimeCreateDto.point_id
        };
    }

    public static PointTimeDisplayDto ToPointTimeDisplayDto(this PointTime pointTime)
    {
        return new PointTimeDisplayDto {
            id = pointTime.id,
            start_time = pointTime.start_time,
            end_time = pointTime.end_time,
            start_date = pointTime.start_date,
            end_date = pointTime.end_date,
            point_id = pointTime.point_id
        };
    }
}