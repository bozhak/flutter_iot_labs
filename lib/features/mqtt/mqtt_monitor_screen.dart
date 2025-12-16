// features/mqtt/mqtt_monitor_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/mqtt_service.dart';
import '../../core/models/server_status_model.dart';

class MqttMonitorScreen extends StatefulWidget {
  final MqttService mqttService;

  const MqttMonitorScreen({
    super.key,
    required this.mqttService,
  });

  @override
  State<MqttMonitorScreen> createState() => _MqttMonitorScreenState();
}

class _MqttMonitorScreenState extends State<MqttMonitorScreen> {
  ServerStatus? _currentStatus;
  final List<ServerStatus> _history = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToMqtt();
  }

  void _subscribeToMqtt() {
    _subscription = widget.mqttService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
          _history.insert(0, status);
          if (_history.length > 10) {
            _history.removeLast();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Server Monitor'),
        centerTitle: true,
      ),
      body: _currentStatus == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Очікування даних з MQTT...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Переконайтеся, що запущено MQTT publisher',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Статус сервера
            Card(
              color: _currentStatus!.online
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _currentStatus!.online
                              ? Icons.check_circle
                              : Icons.error,
                          color: _currentStatus!.online
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Server Status',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _currentStatus!.online ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _currentStatus!.online
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _formatTime(_currentStatus!.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // CPU
            _buildMetricCard(
              'CPU Usage',
              _currentStatus!.cpu,
              Icons.memory,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            // RAM
            _buildMetricCard(
              'RAM Usage',
              _currentStatus!.ram,
              Icons.storage,
              Colors.purple,
            ),
            const SizedBox(height: 12),

            // Disk
            _buildMetricCard(
              'Disk Usage',
              _currentStatus!.disk,
              Icons.sd_storage,
              Colors.orange,
            ),
            const SizedBox(height: 24),

            // Історія
            if (_history.isNotEmpty) ...[
              const Text(
                'Історія (останні 10 записів)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: _history.map((status) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        status.online ? Icons.check_circle : Icons.error,
                        color: status.online ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      title: Text(
                        'CPU: ${status.cpu.toStringAsFixed(1)}% | RAM: ${status.ram.toStringAsFixed(1)}% | Disk: ${status.disk.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        _formatTime(status.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title,
      double value,
      IconData icon,
      Color color,
      ) {
    final isHigh = value > 80;
    final isWarning = value > 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isHigh
                        ? Colors.red.withOpacity(0.2)
                        : isWarning
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHigh
                          ? Colors.red
                          : isWarning
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isHigh
                      ? Colors.red
                      : isWarning
                      ? Colors.orange
                      : color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusText(value),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(double value) {
    if (value > 80) return '⚠️ Високе навантаження';
    if (value > 60) return '⚡ Помірне навантаження';
    return '✅ Нормальне навантаження';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}