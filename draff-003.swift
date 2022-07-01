import Foundation
import UIKit
import AmazonFling

class FireTVDiscovery: UIViewController {
    
    // Properties
    private var discoveryController: DiscoveryController?
    private var selectedDevice: RemoteMediaPlayer?
    private var availableDevices = [RemoteMediaPlayer]()
    
    override func viewDidLoad() {
        discoveryController = DiscoveryController()
        discoveryController?.searchPlayer(withId: "amzn.thin.pl", andListener: self, andEnableLogs: true)
    }
}

extension FireTVDiscovery: UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        discoveryController?.resume()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        selectedDevice?.remove(self)
        discoveryController?.close()
    }
}

extension FireTVDiscovery: DiscoveryListener {
    func deviceDiscovered(_ device: RemoteMediaPlayer) {
        print("device is discovered")
    }
    
    func deviceLost(_ device: RemoteMediaPlayer) {
        print("device is lost")
    }
    
    func discoveryFailure() {
        print("discovery failure")
    }
}
