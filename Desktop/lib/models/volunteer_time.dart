class VolunteerTime {
  final int id;
  final int volunteerId;
  final int day;
  final String startTime;
  final String endTime;

  VolunteerTime({
    required this.id,
    required this.volunteerId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory VolunteerTime.fromJson(Map<String, dynamic> json) {
    return VolunteerTime(
      id: json['id'],
      volunteerId: json['volunteer_id'],
      day: json['day'] is int ? json['day'] : int.parse(json['day'].toString()),
      startTime: json['start_time'].toString(),
      endTime: json['end_time'].toString(),
    );
  }
}
