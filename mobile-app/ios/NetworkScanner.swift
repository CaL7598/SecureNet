import Foundation
import Network
import SystemConfiguration

@objc(NetworkScanner)
class NetworkScanner: NSObject {
  
  @objc
  func getLocalNetworkInfo(_ resolve: @escaping RCTPromiseResolveBlock,
                           rejecter reject: @escaping RCTPromiseRejectBlock) {
    var address: String?
    var netmask: String?
    
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else {
      reject("NETWORK_ERROR", "Failed to get network interfaces", nil)
      return
    }
    defer { freeifaddrs(ifaddr) }
    
    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }
      
      let interface = ptr?.pointee
      let addrFamily = interface?.ifa_addr.pointee.sa_family
      
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: interface!.ifa_name)
        if name == "en0" || name == "en1" {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface?.ifa_addr, socklen_t(interface?.ifa_addr.pointee.sa_len ?? 0),
                     &hostname, socklen_t(hostname.count),
                     nil, socklen_t(0), NI_NUMERICHOST)
          address = String(cString: hostname)
          
          if let netmaskPtr = interface?.ifa_netmask {
            var netmaskHostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(netmaskPtr, socklen_t(netmaskPtr.pointee.sa_len),
                       &netmaskHostname, socklen_t(netmaskHostname.count),
                       nil, socklen_t(0), NI_NUMERICHOST)
            netmask = String(cString: netmaskHostname)
          }
        }
      }
    }
    
    let result: [String: String] = [
      "ipAddress": address ?? "",
      "subnetMask": netmask ?? "",
      "gateway": "" // Gateway detection requires additional work
    ]
    
    resolve(result)
  }
  
  @objc
  func scanARPTable(_ resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) {
    // iOS doesn't provide direct ARP table access
    // This would require using Network framework or system calls
    // For now, return empty array
    resolve([])
  }
  
  @objc
  func scanPorts(_ ipAddress: String,
                 ports: [NSNumber],
                 resolver resolve: @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) {
    let openPorts = NSMutableArray()
    let group = DispatchGroup()
    
    for portNumber in ports {
      let port = portNumber.intValue
      group.enter()
      
      let connection = NWConnection(host: NWEndpoint.Host(ipAddress),
                                   port: NWEndpoint.Port(integerLiteral: UInt16(port)),
                                   using: .tcp)
      
      connection.stateUpdateHandler = { state in
        switch state {
        case .ready:
          openPorts.add(portNumber)
          connection.cancel()
          group.leave()
        case .failed, .cancelled:
          group.leave()
        default:
          break
        }
      }
      
      connection.start(queue: DispatchQueue.global())
      
      // Timeout after 1 second
      DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
        if connection.state != .ready {
          connection.cancel()
          group.leave()
        }
      }
    }
    
    group.notify(queue: .main) {
      resolve(openPorts)
    }
  }
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
}
