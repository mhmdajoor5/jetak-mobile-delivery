
import Flutter
import UIKit
import IOSSecuritySuite
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
     #if RELEASE
     self.checkSecurity()
     #endif
    GMSServices.provideAPIKey("YOUR KEY HERE")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  func checkSecurity()  {  
    if(runReversedEngineeringCheck()){
        exit(0)
    }
    if (runIntegrityCheck() || runDebugCheck() || runProxyCheck()) {
      exit(0)
    }  
    if(runFridaCheck()){
        exit(0)
    }   
    if(runDYLDCheck()){
        exit(0)
    }  
  }
  private func runIntegrityCheck() -> Bool{
    return SecurityHandler.checkJailbroken() 
  }
  private func runDebugCheck() -> Bool{
    return SecurityHandler.checkRunInEmulator() || SecurityHandler.checkDebugged()
  }
  private func runProxyCheck() -> Bool{
    return SecurityHandler.checkProxied()
  }
   private func runReversedEngineeringCheck() -> Bool{
    return SecurityHandler.checkReverseEngineering()
  }
  private func runFridaCheck() -> Bool {
    return SecurityHandler.isFridaRunning();
  }
  private func runDYLDCheck() -> Bool {
    return SecurityHandler.checkDYLD();
  }
}



class SecurityHandler {
  static func checkJailbroken() -> Bool{
    return IOSSecuritySuite.amIJailbroken()
  }
  static func checkRunInEmulator() -> Bool{
    return IOSSecuritySuite.amIRunInEmulator()
  }
   static func checkDebugged() -> Bool{
    return IOSSecuritySuite.amIDebugged()
  }
  static func checkProxied() -> Bool{
    return IOSSecuritySuite.amIProxied()
  }
  static func checkReverseEngineering() -> Bool{
    return IOSSecuritySuite.amIReverseEngineered()
  }

  static func isFridaRunning() -> Bool {
    let ports = [27042, 27043, 27044] // Add more if necessary
    for port in ports {
      if checkPort(port: in_port_t(port)) {
          return true
      }
    }
    return false
  }
  static func checkPort(port: in_port_t) -> Bool {
    func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
        let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return littleEndian ? _OSSwapInt16(port) : port
    }
    var serverAddress = sockaddr_in()
    serverAddress.sin_family = sa_family_t(AF_INET)
    serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
    serverAddress.sin_port = swapBytesIfNeeded(port: port)
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    defer { close(sock) }
    let result = withUnsafePointer(to: &serverAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
        }
import Flutter
import UIKit
import IOSSecuritySuite
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
     #if RELEASE
     self.checkSecurity()
     #endif
    GMSServices.provideAPIKey("YOUR KEY HERE")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  func checkSecurity()  {  
    if(runReversedEngineeringCheck()){
        exit(0)
    }
    if (runIntegrityCheck() || runDebugCheck() || runProxyCheck()) {
      exit(0)
    }  
    if(runFridaCheck()){
        exit(0)
    }   
    if(runDYLDCheck()){
        exit(0)
    }  
  }
  private func runIntegrityCheck() -> Bool{
    return SecurityHandler.checkJailbroken() 
  }
  private func runDebugCheck() -> Bool{
    return SecurityHandler.checkRunInEmulator() || SecurityHandler.checkDebugged()
  }
  private func runProxyCheck() -> Bool{
    return SecurityHandler.checkProxied()
  }
   private func runReversedEngineeringCheck() -> Bool{
    return SecurityHandler.checkReverseEngineering()
  }
  private func runFridaCheck() -> Bool {
    return SecurityHandler.isFridaRunning();
  }
  private func runDYLDCheck() -> Bool {
    return SecurityHandler.checkDYLD();
  }
}



class SecurityHandler {
  static func checkJailbroken() -> Bool{
    return IOSSecuritySuite.amIJailbroken()
  }
  static func checkRunInEmulator() -> Bool{
    return IOSSecuritySuite.amIRunInEmulator()
  }
   static func checkDebugged() -> Bool{
    return IOSSecuritySuite.amIDebugged()
  }
  static func checkProxied() -> Bool{
    return IOSSecuritySuite.amIProxied()
  }
  static func checkReverseEngineering() -> Bool{
    return IOSSecuritySuite.amIReverseEngineered()
  }

  static func isFridaRunning() -> Bool {
    let ports = [27042, 27043, 27044] // Add more if necessary
    for port in ports {
      if checkPort(port: in_port_t(port)) {
          return true
      }
    }
    return false
  }
  static func checkPort(port: in_port_t) -> Bool {
    func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
        let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        return littleEndian ? _OSSwapInt16(port) : port
    }
    var serverAddress = sockaddr_in()
    serverAddress.sin_family = sa_family_t(AF_INET)
    serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
    serverAddress.sin_port = swapBytesIfNeeded(port: port)
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    defer { close(sock) }
    let result = withUnsafePointer(to: &serverAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
        }
    }
    return result != -1
  }
  static func checkDYLD() -> Bool {
    let suspiciousLibraries = [
        "FridaGadget",
        "frida",
        "cynject",
        "libcycript"
    ]
    for library in suspiciousLibraries {
        if let handle = dlopen(library, RTLD_NOW | RTLD_NOLOAD) {
            dlclose(handle)
            return true
        }
    }
    return false
  }
}





    }
    return result != -1
  }
  static func checkDYLD() -> Bool {
    let suspiciousLibraries = [
        "FridaGadget",
        "frida",
        "cynject",
        "libcycript"
    ]
    for library in suspiciousLibraries {
        if let handle = dlopen(library, RTLD_NOW | RTLD_NOLOAD) {
            dlclose(handle)
            return true
        }
    }
    return false
  }
}




