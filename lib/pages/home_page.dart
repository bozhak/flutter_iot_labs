import 'package:flutter/material.dart';
import '../proxmox_api.dart';
import '/node_status.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ProxmoxApi api;
  NodeStatus? nodeStatus;
  String? error;

  @override
  void initState() {
    super.initState();
    api = ProxmoxApi(
      baseUrl: 'https://not-pwned.fun/api2/json',
      apiToken: 'root@pam!monitoring=bbdc4e94-c43d-44e4-867f-f754c9aeb008',
    );
    fetchNode();
  }

  Future<void> fetchNode() async {
    try {
      final status = await api.getNodeStatus('not-pwned');
      setState(() {
        nodeStatus = status;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final username = args['username'] ?? args['email'] ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile', arguments: args),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: nodeStatus == null
            ? error != null
            ? Center(child: Text('Error: $error'))
            : Center(child: CircularProgressIndicator())
            : NodeStatusWidget(api: api),
      ),
    );
  }
}
