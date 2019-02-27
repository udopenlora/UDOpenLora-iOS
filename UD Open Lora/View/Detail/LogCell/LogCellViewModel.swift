//
//  LogCellViewModel.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/8/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import Foundation

final class LogCellViewModel: ViewModel {
    // MARK: - Properties
    var log: Log
    
    // MARK: - Init
    init(log: Log) {
        self.log = log
    }
    
    // MARK: - Functions
    func convertToDatetime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT +0")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
}
