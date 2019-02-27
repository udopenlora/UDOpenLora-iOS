//
//  DeviceCellViewModel.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/8/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import Foundation

class ViewModel {
}

final class DeviceCellViewModel: ViewModel {
    var devices: Device
    
    init(device: Device) {
        self.devices = device
    }
}
