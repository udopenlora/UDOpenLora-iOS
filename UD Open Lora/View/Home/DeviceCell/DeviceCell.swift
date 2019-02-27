//
//  DeviceCell.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/8/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var availableView: UIView!
    
    // MARK: - Properties
    var viewModel: DeviceCellViewModel? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    // MARK: - Private functions
    private func configureUI() {
        availableView.layer.cornerRadius = availableView.bounds.height / 2
        availableView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    private func updateView() {
        nameLabel.text = viewModel?.devices.name
        guard let available = viewModel?.devices.available else { return }
        availableView.backgroundColor = available ? #colorLiteral(red: 0.1607843137, green: 0.7098039216, blue: 0.6588235294, alpha: 1) : #colorLiteral(red: 0.7411764706, green: 0.7568627451, blue: 0.7843137255, alpha: 1)
    }

}
