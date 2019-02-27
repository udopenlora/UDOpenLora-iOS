//
//  CurrentDataObj.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CurrentData {
    
    var id: String?
    var status: Bool?
    
    init(id: String, data: JSON) {
        self.id = id
        self.status = data["status"].bool
    }
}
