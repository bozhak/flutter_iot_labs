import 'dart:async';
import 'package:flutter/material.dart';
import 'proxmox_api.dart';
import 'node_status.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ProxmoxApi api = ProxmoxApi(
    baseUrl: 'https://not-pwned.fun/api2/json',
    apiToken: 'root@pam!monitoring=bbdc4e94-c43d-44e4-867f-f754c9aeb008',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxmox Dashboard',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(title: Text('Proxmox Dashboard')),
        body: NodeStatusWidget(api: api),
      ),
    );
  }
}

class NodeStatusWidget extends StatefulWidget {
  final ProxmoxApi api;

  NodeStatusWidget({required this.api});

  @override
  _NodeStatusWidgetState createState() => _NodeStatusWidgetState();
}

class _NodeStatusWidgetState extends State<NodeStatusWidget> {
  NodeStatus? nodeStatus;
  String? error;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(Duration(seconds: 5), (t) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final data = await widget.api.getNodeStatus('not-pwned');
      setState(() {
        nodeStatus = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(2)} KB";
    final mb = kb / 1024;
    if (mb < 1024) return "${mb.toStringAsFixed(2)} MB";
    final gb = mb / 1024;
    return "${gb.toStringAsFixed(2)} GB";
  }

  String formatUptime(int seconds) {
    if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '$minutes min';
    } else {
      final hours = seconds ~/ 3600;
      return '$hours h';
    }
  }

  Color getCpuColor(double cpu) {
    if (cpu < 0.5) return Colors.green;
    if (cpu < 0.8) return Colors.orange;
    return Colors.red;
  }

  Color getRamColor(double used, double total) {
    final ratio = used / total;
    if (ratio < 0.5) return Colors.green;
    if (ratio < 0.8) return Colors.orange;
    return Colors.red;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'running':
        return Colors.green;
      case 'stopped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildSectionTitle(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  Widget buildVmCard(VM vm) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${vm.name} (ID: ${vm.vmid})',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: getStatusColor(vm.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(vm.status,
                      style: TextStyle(
                          color: getStatusColor(vm.status),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 8),
            // CPU
            Text('CPU Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            LinearProgressIndicator(
              value: vm.cpu,
              color: getCpuColor(vm.cpu),
              backgroundColor: Colors.grey[300],
              minHeight: 6,
            ),
            SizedBox(height: 4),
            Text('vCPU: ${vm.cpus}  |  CPU: ${(vm.cpu * 100).toStringAsFixed(1)}%'),
            SizedBox(height: 8),
            // RAM
            Text('RAM Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            LinearProgressIndicator(
              value: vm.memoryTotal == 0 ? 0 : vm.memoryUsed / vm.memoryTotal,
              color:
              getRamColor(vm.memoryUsed.toDouble(), vm.memoryTotal.toDouble()),
              backgroundColor: Colors.grey[300],
              minHeight: 6,
            ),
            SizedBox(height: 4),
            Text('RAM: ${formatBytes(vm.memoryUsed)} / ${formatBytes(vm.memoryTotal)}'),
            SizedBox(height: 8),
            // Network + Uptime
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Network: ${formatBytes(vm.netIn)} / ${formatBytes(vm.netOut)}'),
                Text('Uptime: ${formatUptime(vm.uptime)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) return Center(child: Text('Error: $error'));
    if (nodeStatus == null) return Center(child: CircularProgressIndicator());

    final node = nodeStatus!;

    // Сортуємо VM за vmid
    final sortedVms = [...node.vms]..sort((a, b) => a.vmid.compareTo(b.vmid));

    return RefreshIndicator(
      onRefresh: fetchData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle('Node Summary', Icons.memory, Colors.blueGrey),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: node.cpu,
                            color: getCpuColor(node.cpu),
                            backgroundColor: Colors.grey[300],
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('CPU: ${(node.cpu * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: node.memoryTotal == 0 ? 0 : node.memoryUsed / node.memoryTotal,
                            color: getRamColor(node.memoryUsed.toDouble(), node.memoryTotal.toDouble()),
                            backgroundColor: Colors.grey[300],
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('RAM: ${formatBytes(node.memoryUsed)} / ${formatBytes(node.memoryTotal)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Disk: ${formatBytes(node.diskUsed)} / ${formatBytes(node.diskTotal)}'),
                        Text('Uptime: ${formatUptime(node.uptime)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            buildSectionTitle('VMs', Icons.desktop_windows, Colors.teal),
            ...sortedVms.map((vm) => buildVmCard(vm)),
          ],
        ),
      ),
    );
  }
}
