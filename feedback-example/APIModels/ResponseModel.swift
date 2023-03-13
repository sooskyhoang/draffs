//
//  ResponseModel.swift
//  GiftConsultant
//
//  Created by Anh Tu on 2/21/20.
//  Copyright © 2020 NTQ. All rights reserved.
//

import Foundation

struct ResponseModel<T: Codable>: Codable {
    var status: String
    var message: String
    var data: T?
}
