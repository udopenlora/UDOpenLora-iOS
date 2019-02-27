//
//  DetailViewController.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    // MARK: - IBoutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentSwitch: UISwitch!
    @IBOutlet weak var nameOfDeviceLabel: UILabel!
    
    // MARK: - Properties
    private var isLoadmore = false
    var viewModel =  DetailViewModel(id: "", nameOfDevice: "") {
        didSet {
            viewModel.fetchDataFromFireBase { (result) in
                switch result {
                case true:
                    print(self.viewModel.logArray.count)
                    self.updateView()
                case false: break
                }
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Private functions
    private func configureUI() {
        // cell register
        let cellNib = UINib(nibName: "LogCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "LogCell")
        
        // delegate, datasource
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func updateView() {
        tableView.reloadData()
        if let status = viewModel.current?.status {
            currentSwitch.isOn = status
        }
        nameOfDeviceLabel.text = viewModel.nameOfDevice
    }
    
    // MARK: - IBAction
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        viewModel.toggleDevice(status: currentSwitch.isOn)
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = viewModel.logArray.count - 1
        if indexPath.row == lastItem {
            
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItem(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as? LogCell else { fatalError() }
        cell.viewModel = viewModel.viewModelForItem(at: indexPath.row) as? LogCellViewModel
        return cell
    }
}
