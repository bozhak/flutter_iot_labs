class NodeStatus {
  final double cpu;
  final int memoryUsed;
  final int memoryTotal;
  final int uptime;
  final int diskUsed;
  final int diskTotal;
  final List<VM> vms;
  final List<VM> lxc;

  NodeStatus({
    required this.cpu,
    required this.memoryUsed,
    required this.memoryTotal,
    required this.uptime,
    required this.diskUsed,
    required this.diskTotal,
    required this.vms,
    required this.lxc,
  });

  factory NodeStatus.fromJson(Map<String, dynamic> json, {List<VM>? vms, List<VM>? lxc}) {
    return NodeStatus(
      cpu: (json['cpu'] ?? 0).toDouble(),
      memoryUsed: json['memory']?['used'] ?? 0,
      memoryTotal: json['memory']?['total'] ?? 0,
      uptime: json['uptime'] ?? 0,
      diskUsed: json['disk']?['used'] ?? 0,
      diskTotal: json['disk']?['total'] ?? 0,
      vms: vms ?? [],
      lxc: lxc ?? [],
    );
  }
}

class VM {
  final int vmid;
  final String name;
  final String status;
  final double cpu;
  final int cpus;
  final int memoryUsed;
  final int memoryTotal;
  final int diskRead;
  final int diskWrite;
  final int netIn;
  final int netOut;
  final int uptime;

  VM({
    required this.vmid,
    required this.name,
    required this.status,
    required this.cpu,
    required this.cpus,
    required this.memoryUsed,
    required this.memoryTotal,
    required this.diskRead,
    required this.diskWrite,
    required this.netIn,
    required this.netOut,
    required this.uptime,
  });

  factory VM.fromJson(Map<String, dynamic> json) {
    return VM(
      vmid: json['vmid'] ?? 0,
      name: json['name'] ?? 'unknown',
      status: json['status'] ?? 'unknown',
      cpu: (json['cpu'] ?? 0).toDouble(),
      cpus: json['cpus'] ?? 0,
      memoryUsed: json['mem'] ?? 0,
      memoryTotal: json['maxmem'] ?? 0,
      diskRead: json['diskread'] ?? 0,
      diskWrite: json['diskwrite'] ?? 0,
      netIn: json['netin'] ?? 0,
      netOut: json['netout'] ?? 0,
      uptime: json['uptime'] ?? 0, // <- беремо з API
    );
  }
}

