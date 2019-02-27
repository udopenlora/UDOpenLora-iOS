//
//  DetailViewModel.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

final class DetailViewModel: ViewModel {

    // MARK: - Properties
    var logArray: [Log] = []
    var id: String
    var current: CurrentData?
    var nameOfDevice: String

    // MARK: - Init
    init(id: String, nameOfDevice: String) {
        self.id = id
        self.nameOfDevice = nameOfDevice
    }

    // MARK: - Functions
    func fetchDataFromFireBase(completion: @escaping (Bool) -> ()) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            guard let deviceLog = postDict["device_log"] as? [String: AnyObject],
                let currentData = postDict["current_data"] as? [String: Any] else { return }
            self.logArray.removeAll()
            
            for item in deviceLog {
                if item.key == self.id {
                    guard let logs = item.value as? [String: Any] else { return }
                    for log in logs {
                        let json = JSON(log.value)
                        let data = Log(data: json, id: item.key)
                        self.logArray.append(data)
                    }
                }
            }
            for item in currentData {
                if item.key == self.id {
                    let json = JSON(item.value)
                    self.current = CurrentData(id: self.id, data: json)
                }
            }
            self.logArray = self.logArray.sorted(by: { $0.timeStamp! > $1.timeStamp! })
            completion(true)
        })
    }
    
    func numberOfItem(in section: Int) -> Int {
        return logArray.count
    }
    
    func viewModelForItem(at index: Int) -> ViewModel {
        let log = logArray[index]
        return LogCellViewModel(log: log)
    }
    
    func toggleDevice(status: Bool) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("current_data").child(id).setValue(["status": status])

        let serverTime = ServerValue.timestamp()
        guard let autoKey = ref.child("device_log").child(id).childByAutoId().key else { return }
        let key = String(autoKey)
        let data = ["status": status]
        let post = ["data": data,
                    "source_control": "iOS",
                    "timestamp": serverTime,
                    ] as [String : Any] 
        let childUpdates = ["/device_log/\(id)/\(key)": post]
        ref.updateChildValues(childUpdates)
    }
}
