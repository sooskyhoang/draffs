//
//  Helpers.swift
//  chatGPT2
//
//  Created by nguyen van hoang on 03/03/2023.
//

import Foundation

class Helpers {
    class func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
