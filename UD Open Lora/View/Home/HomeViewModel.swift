//
//  HomeViewModel.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import AI

final class HomeViewModel: ViewModel {
    
    // MARK: - Propertie
    var devices: [Device] = []
    
    // MARK: - Functions
    func fetchDataFromFireBase(completion: @escaping (Bool) -> ()) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            guard let devicesDic = postDict["devices"] as? [String: Any] else { return }
            self.devices.removeAll()
            for device in devicesDic {
                let json = JSON(device.value)
                let device = Device(data: json, id: device.key)
                self.devices.append(device)
            }
            completion(true)
        })
    }
    
    func requestChatBot(text: String, completion: @escaping (String) -> Void) {
        AI.sharedService.textRequest(text)
            .success { (response) -> Void in
                guard let fullfillment = response.result.fulfillment?.speech else { return }
                let newString = fullfillment.replacingOccurrences(of: "</br>", with: "\n")
                completion(newString)
            }
            .failure { (error) -> Void in
                completion(error.localizedDescription)
        }
    }
    
    func numberOfRow(in section: Int) -> Int {
        return self.devices.count
    }
    
    func viewModelForItem(at index: Int) -> ViewModel {
        let device = devices[index]
        return DeviceCellViewModel(device: device)
    }
}
