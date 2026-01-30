/**
 * TypeScript type definitions for SecureNet
 */

export enum RiskLevel {
  SECURE = 'SECURE',
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

export enum IssueType {
  INSECURE_PORT = 'INSECURE_PORT',
  DEFAULT_CREDENTIALS = 'DEFAULT_CREDENTIALS',
  KNOWN_VULNERABILITY = 'KNOWN_VULNERABILITY',
  WEAK_PROTOCOL = 'WEAK_PROTOCOL',
}

export enum Severity {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

export interface DeviceScan {
  ip_address: string;
  mac_address: string;
  device_name?: string;
  open_ports: number[];
  vendor?: string;
}

export interface Issue {
  type: IssueType;
  severity: Severity;
  port?: number;
  description: string;
  recommendation: string;
}

export interface DeviceAnalysis {
  ip_address: string;
  mac_address: string;
  device_name?: string;
  risk_level: RiskLevel;
  security_score: number;
  issues: Issue[];
}

export interface NetworkAnalysis {
  network_score: number;
  overall_risk: RiskLevel;
  total_devices: number;
  critical_issues: number;
  high_risk_devices: number;
  devices: DeviceAnalysis[];
}

export interface ScanSettings {
  scanInterval: 'manual' | '1hour' | '6hours' | '24hours';
  defaultScanMode: 'real' | 'demo';
  enableNotifications: boolean;
  criticalAlerts: boolean;
  highRiskAlerts: boolean;
}

export interface ScanHistory {
  id: string;
  timestamp: Date;
  network_score: number;
  overall_risk: RiskLevel;
  total_devices: number;
  critical_issues: number;
}
