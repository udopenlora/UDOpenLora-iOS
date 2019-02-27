//
//  LogCell.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/8/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sourceControlLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    // MARK: - Properties
    var viewModel: LogCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Private functions
    private func updateView() {
        if viewModel?.log.status == true {
            statusLabel.text = "ON"
        } else {
            statusLabel.text = "OFF"
        }
        sourceControlLabel.text = viewModel?.log.sourceControl
        guard let timestamp = viewModel?.log.timeStamp else { return }
        timestampLabel.text = viewModel?.convertToDatetime(from: timestamp)
    }
}
