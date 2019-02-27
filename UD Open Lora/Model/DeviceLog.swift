//
//  DeviceLog.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Log: NSObject {
    
    var status: Bool?
    var sourceControl: String?
    var timeStamp: Double?
    var id: String?
    
    init(data: JSON, id: String) {
        self.status = data["data"]["status"].bool
        self.sourceControl = data["source_control"].string
        self.timeStamp = data["timestamp"].double
        self.id = id
    }
}
