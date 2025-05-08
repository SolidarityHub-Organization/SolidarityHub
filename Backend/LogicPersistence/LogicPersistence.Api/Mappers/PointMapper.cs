namespace LogicPersistence.Api.Mappers;

using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;

public static class PointMapper 
{
    public static PickupPoint ToPickupPoint(this PickupPointCreateDto pickupPointCreateDto) 
    {
        return new PickupPoint {
            name = pickupPointCreateDto.name,
            description = pickupPointCreateDto.description,
            created_at = pickupPointCreateDto.created_at,
            time_id = pickupPointCreateDto.time_id,
            location_id = pickupPointCreateDto.location_id,
            admin_id = pickupPointCreateDto.admin_id
        };
    }

    
        public static PickupPoint ToPickupPoint(this PickupPointUpdateDto pickupPointUpdateDto) 
        {
            return new PickupPoint {
                id = pickupPointUpdateDto.id,
                name = pickupPointUpdateDto.name,
                description = pickupPointUpdateDto.description,
                created_at = pickupPointUpdateDto.created_at,
                time_id = pickupPointUpdateDto.time_id,
                location_id = pickupPointUpdateDto.location_id,
                admin_id = pickupPointUpdateDto.admin_id
            };
        }


    
        public static MeetingPoint ToMeetingPoint(this MeetingPointCreateDto meetingPointCreateDto) 
        {
            return new MeetingPoint {
                name = meetingPointCreateDto.name,
                description = meetingPointCreateDto.description,
                created_at = meetingPointCreateDto.created_at,
                time_id = meetingPointCreateDto.time_id,
                location_id = meetingPointCreateDto.location_id,
                admin_id = meetingPointCreateDto.admin_id
            };
        }

        public static MeetingPoint ToMeetingPoint(this MeetingPointUpdateDto meetingPointUpdateDto) 
        {
            return new MeetingPoint {
                id = meetingPointUpdateDto.id,
                name = meetingPointUpdateDto.name,
                description = meetingPointUpdateDto.description,
                created_at = meetingPointUpdateDto.created_at,
                time_id = meetingPointUpdateDto.time_id,
                location_id = meetingPointUpdateDto.location_id,
                admin_id = meetingPointUpdateDto.admin_id
            };
        }

        public static PickupPointDisplayDto ToPickupPointDisplayDto(this PickupPoint pickupPoint) 
        {
            return new PickupPointDisplayDto {
                id = pickupPoint.id,
                name = pickupPoint.name,
                description = pickupPoint.description,
                created_at = pickupPoint.created_at,
                time_id = pickupPoint.time_id,
                location_id = pickupPoint.location_id,
                admin_id = pickupPoint.admin_id
            };
        }
        public static MeetingPointDisplayDto ToMeetingPointDisplayDto(this MeetingPoint meetingPoint) 
        {
            return new MeetingPointDisplayDto {
                id = meetingPoint.id,
                name = meetingPoint.name,
                description = meetingPoint.description,
                created_at = meetingPoint.created_at,
                time_id = meetingPoint.time_id,
                location_id = meetingPoint.location_id,
                admin_id = meetingPoint.admin_id
            };
        }
}