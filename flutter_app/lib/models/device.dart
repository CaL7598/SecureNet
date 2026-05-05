enum RiskLevel { secure, low, medium, high, critical }

enum Severity { low, medium, high, critical }

class DeviceScan {
  final String ipAddress;
  final String macAddress;
  final String? deviceName;
  final List<int> openPorts;
  final String? vendor;

  DeviceScan({
    required this.ipAddress,
    required this.macAddress,
    this.deviceName,
    List<int>? openPorts,
    this.vendor,
  }) : openPorts = openPorts ?? [];

  Map<String, dynamic> toJson() => {
        'ip_address': ipAddress,
        'mac_address': macAddress,
        if (deviceName != null) 'device_name': deviceName,
        'open_ports': openPorts,
        if (vendor != null) 'vendor': vendor,
      };
}

class Issue {
  final String type;
  final String severity;
  final int? port;
  final String description;
  final String recommendation;

  Issue({
    required this.type,
    required this.severity,
    this.port,
    required this.description,
    required this.recommendation,
  });

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        type: json['type'] as String? ?? '',
        severity: json['severity'] as String? ?? 'LOW',
        port: json['port'] as int?,
        description: json['description'] as String? ?? '',
        recommendation: json['recommendation'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'severity': severity,
        if (port != null) 'port': port,
        'description': description,
        'recommendation': recommendation,
      };
}

class DeviceAnalysis {
  final String ipAddress;
  final String macAddress;
  final String? deviceName;
  final String? manufacturer;
  final String? deviceKind;
  final String riskLevel;
  final int securityScore;
  final List<Issue> issues;

  DeviceAnalysis({
    required this.ipAddress,
    required this.macAddress,
    this.deviceName,
    this.manufacturer,
    this.deviceKind,
    required this.riskLevel,
    required this.securityScore,
    List<Issue>? issues,
  }) : issues = issues ?? [];

  factory DeviceAnalysis.fromJson(Map<String, dynamic> json) => DeviceAnalysis(
        ipAddress: json['ip_address'] as String? ?? '',
        macAddress: json['mac_address'] as String? ?? '',
        deviceName: json['device_name'] as String?,
        manufacturer: json['manufacturer'] as String?,
        deviceKind: json['device_kind'] as String?,
        riskLevel: json['risk_level'] as String? ?? 'SECURE',
        securityScore: json['security_score'] as int? ?? 0,
        issues: (json['issues'] as List<dynamic>?)
                ?.map((e) => Issue.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'ip_address': ipAddress,
        'mac_address': macAddress,
        if (deviceName != null) 'device_name': deviceName,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (deviceKind != null) 'device_kind': deviceKind,
        'risk_level': riskLevel,
        'security_score': securityScore,
        'issues': issues.map((e) => e.toJson()).toList(),
      };
}

class NetworkAnalysis {
  final int networkScore;
  final String overallRisk;
  final int totalDevices;
  final int criticalIssues;
  final int highRiskDevices;
  final int confidenceScore;
  final List<DeviceAnalysis> devices;

  NetworkAnalysis({
    required this.networkScore,
    required this.overallRisk,
    required this.totalDevices,
    required this.criticalIssues,
    required this.highRiskDevices,
    this.confidenceScore = 0,
    List<DeviceAnalysis>? devices,
  }) : devices = devices ?? [];

  factory NetworkAnalysis.fromJson(Map<String, dynamic> json) => NetworkAnalysis(
        networkScore: json['network_score'] as int? ?? 0,
        overallRisk: json['overall_risk'] as String? ?? 'SECURE',
        totalDevices: json['total_devices'] as int? ?? 0,
        criticalIssues: json['critical_issues'] as int? ?? 0,
        highRiskDevices: json['high_risk_devices'] as int? ?? 0,
        confidenceScore: json['confidence_score'] as int? ?? 0,
        devices: (json['devices'] as List<dynamic>?)
                ?.map((e) => DeviceAnalysis.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'network_score': networkScore,
        'overall_risk': overallRisk,
        'total_devices': totalDevices,
        'critical_issues': criticalIssues,
        'high_risk_devices': highRiskDevices,
        'confidence_score': confidenceScore,
        'devices': devices.map((e) => e.toJson()).toList(),
      };
}

class ScanHistoryEntry {
  final DateTime scannedAt;
  final NetworkAnalysis analysis;

  ScanHistoryEntry({
    required this.scannedAt,
    required this.analysis,
  });

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) => ScanHistoryEntry(
        scannedAt: DateTime.parse(
          json['scanned_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        analysis: NetworkAnalysis.fromJson(
          json['analysis'] as Map<String, dynamic>? ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'scanned_at': scannedAt.toIso8601String(),
        'analysis': analysis.toJson(),
      };
}
