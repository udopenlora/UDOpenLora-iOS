//
//  Devices.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Device: NSObject {

    var id: String?
    var name: String?
    var type: String?
    var available: Bool?

    init(data: JSON, id: String) {
        self.id = id
        self.name = data["name"].string
        self.type = data["type"].string
        self.available = data["available"].bool
    }
}
