//
//  KeychainManager.swift
//  chatGPT2
//
//  Created by nguyen van hoang on 17/01/2023.
//

import Foundation
import SwiftKeychainWrapper

class KeychainManager {
    static let shared = KeychainManager()
    
    func getDeviceIdentifier() -> String {
        if let deviceUDID = KeychainWrapper.standard.string(forKey: "keychainDeviceUDID") {
            return deviceUDID
        } else {
            let id = UIDevice.current.identifierForVendor!.uuidString + "_" + Helpers.randomString(length: 25)
            KeychainWrapper.standard.set(id, forKey: "keychainDeviceUDID")
            return id
        }
    }
}
