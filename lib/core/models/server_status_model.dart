// core/models/server_status_model.dart

class ServerStatus {
  final double cpu;
  final double ram;
  final double disk;
  final bool online;
  final DateTime timestamp;

  const ServerStatus({
    required this.cpu,
    required this.ram,
    required this.disk,
    required this.online,
    required this.timestamp,
  });

  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      cpu: (json['cpu'] as num).toDouble(),
      ram: (json['ram'] as num).toDouble(),
      disk: (json['disk'] as num).toDouble(),
      online: json['online'] as bool? ?? true,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': cpu,
      'ram': ram,
      'disk': disk,
      'online': online,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ServerStatus copyWith({
    double? cpu,
    double? ram,
    double? disk,
    bool? online,
    DateTime? timestamp,
  }) {
    return ServerStatus(
      cpu: cpu ?? this.cpu,
      ram: ram ?? this.ram,
      disk: disk ?? this.disk,
      online: online ?? this.online,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}