class PrayerTimeModel {
  final String name;
  String time; // Format: "HH:mm"
  bool isEnabled;

  PrayerTimeModel({
    required this.name,
    required this.time,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'isEnabled': isEnabled,
    };
  }

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimeModel(
      name: json['name'],
      time: json['time'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  PrayerTimeModel copyWith({
    String? name,
    String? time,
    bool? isEnabled,
  }) {
    return PrayerTimeModel(
      name: name ?? this.name,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
