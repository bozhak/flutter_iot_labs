// core/services/mqtt_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/server_status_model.dart';

class MqttService {
  static const String _broker = 'test.mosquitto.org';
  static const int _port = 1883;
  static const String _topic = 'proxmox/server1/status';

  MqttServerClient? _client;
  final _statusController = StreamController<ServerStatus>.broadcast();
  final _connectionController = StreamController<MqttConnectionState>.broadcast();

  Stream<ServerStatus> get statusStream => _statusController.stream;
  Stream<MqttConnectionState> get connectionStream => _connectionController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect() async {
    try {
      _client = MqttServerClient(_broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
      _client!.port = _port;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 60;
      _client!.autoReconnect = true;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _subscribeToTopic();
        return true;
      }

      return false;
    } catch (e) {
      print('MQTT Connection Error: $e');
      return false;
    }
  }

  void _subscribeToTopic() {
    _client!.subscribe(_topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMessage = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      try {
        final json = jsonDecode(payload) as Map<String, dynamic>;
        final status = ServerStatus.fromJson(json);
        _statusController.add(status);
      } catch (e) {
        print('Error parsing MQTT message: $e');
      }
    });
  }

  void _onConnected() {
    print('MQTT Connected');
    _connectionController.add(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
    _connectionController.add(MqttConnectionState.disconnected);
  }

  void _onAutoReconnect() {
    print('MQTT Auto Reconnecting...');
    _connectionController.add(MqttConnectionState.connecting);
  }

  void _onAutoReconnected() {
    print('MQTT Auto Reconnected');
    _connectionController.add(MqttConnectionState.connected);
    _subscribeToTopic();
  }

  void disconnect() {
    _client?.disconnect();
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _connectionController.close();
  }
}