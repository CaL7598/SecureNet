#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Network/Network.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface RCT_EXTERN_MODULE(NetworkScanner, NSObject)

RCT_EXTERN_METHOD(getLocalNetworkInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(scanARPTable:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(scanPorts:(NSString *)ipAddress
                  ports:(NSArray *)ports
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
