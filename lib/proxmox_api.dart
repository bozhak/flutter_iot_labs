import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'node_status.dart';

class ProxmoxApi {
  final String baseUrl;
  final String apiToken;

  ProxmoxApi({required this.baseUrl, required this.apiToken});

  Future<NodeStatus> getNodeStatus(String nodeName) async {
    HttpOverrides.global = MyHttpOverrides();

    final nodeUrl = Uri.parse('$baseUrl/nodes/$nodeName/status');
    final nodeRes = await http.get(nodeUrl, headers: {
      'Authorization': 'PVEAPIToken=$apiToken',
    });

    if (nodeRes.statusCode != 200) {
      throw Exception('Failed to load node status: ${nodeRes.body}');
    }

    final nodeData = jsonDecode(nodeRes.body)['data'];
    final vms = await getVMs(nodeName);

    return NodeStatus.fromJson(nodeData, vms: vms);
  }

  Future<List<VM>> getVMs(String nodeName) async {
    final url = Uri.parse('$baseUrl/nodes/$nodeName/qemu');
    final res = await http.get(url, headers: {
      'Authorization': 'PVEAPIToken=$apiToken',
    });

    if (res.statusCode != 200) return [];
    final List<dynamic>? data = jsonDecode(res.body)['data'];
    if (data == null) return [];
    return data.map((vm) => VM.fromJson(vm)).toList();
  }

  Future<List<VM>> getLXC(String nodeName) async {
    final url = Uri.parse('$baseUrl/nodes/$nodeName/lxc');
    final res = await http.get(url, headers: {
      'Authorization': 'PVEAPIToken=$apiToken',
    });

    if (res.statusCode != 200) return [];
    final List<dynamic>? data = jsonDecode(res.body)['data'];
    if (data == null) return [];
    return data.map((vm) => VM.fromJson(vm)).toList();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
