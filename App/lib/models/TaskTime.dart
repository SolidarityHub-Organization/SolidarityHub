class TaskTime {
  final int id;
  final String date;
  final String startTime;
  final String endTime;

  TaskTime({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TaskTime.fromJson(Map<String, dynamic> json) {
    return TaskTime(
      id: json['id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
