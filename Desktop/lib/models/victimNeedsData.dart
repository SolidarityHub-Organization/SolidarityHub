class VictimNeedsData {
  final String need;
  final int count;

  VictimNeedsData({required this.need, required this.count});

  factory VictimNeedsData.fromJson(Map<String, dynamic> json) {
    return VictimNeedsData(need: json['need'], count: json['count']);
  }
}
