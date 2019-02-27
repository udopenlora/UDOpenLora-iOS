//
//  HomeViewController.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit
import Firebase
import Speech
import NVActivityIndicatorView
import TTGSnackbar

final class HomeViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Properties
    let viewModel: HomeViewModel = HomeViewModel()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "vi-VN"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speakTalk = AVSpeechSynthesizer()
    private var activityView: NVActivityIndicatorView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.fetchDataFromFireBase { (result) in
            switch result {
            case true:
                self.tableView.reloadData()
            case false: break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureActivityView()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        // set title
        navigationItem.title = Strings.homeTitle
        
        // cell register
        let cellNib = UINib(nibName: "DeviceCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "DeviceCell")
        
        // delegate, datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        speechButton.layer.cornerRadius = 45/2
        speechButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        speechButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.5)
        speechButton.layer.shadowOpacity = 0.3
        speechButton.layer.shadowRadius = 0.0
        speechButton.layer.masksToBounds = false
        
        // Speech to text
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.speechButton.isEnabled = isButtonEnabled
            }
        }
        
        // Speech to text
        popUpView.isHidden = true
    }
    
    func showPopup(message: String) {
        let snackbar = TTGSnackbar(message: message,
                                   duration: .middle,
                                   actionText: "",
                                   actionBlock: { (snackbar) in
                                    snackbar.dismiss()
        })
        snackbar.animationType = .slideFromTopBackToTop
        snackbar.topMargin = self.navigationController?.navigationBar.frame.height ?? 0.0
        
        snackbar.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        snackbar.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.5568627451, blue: 0.7921568627, alpha: 1)
        snackbar.show()
    }
    
    // MARK: - IBAction
    @IBAction func speechButtonTapped(_ sender: Any) {
        popUpView.isHidden = false
        startRecording()
        startActivityView()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        stopActivityView()
        popUpView.isHidden = true
        resultLabel.text = ""
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        viewModel.requestChatBot(text: resultLabel.text ?? "") { (string) in
            if string.isEmpty || string == "bad request" {
                DispatchQueue.main.async {
                    self.showPopup(message: "Vui lòng cho biết thêm thông tin!")
                    self.resultLabel.text = ""
                }
            } else {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionTask?.cancel()
                self.stopActivityView()
                self.popUpView.isHidden = true
                self.showPopup(message: string)
                self.resultLabel.text = ""
            }
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        guard let id = viewModel.devices[indexPath.row].id,
            let name = viewModel.devices[indexPath.row].name else { return }
        detailVC.viewModel = DetailViewModel(id: id, nameOfDevice: name)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRow(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as? DeviceCell else { fatalError() }
        cell.viewModel = viewModel.viewModelForItem(at: indexPath.row) as? DeviceCellViewModel
        return cell
    }
}

extension HomeViewController: SFSpeechRecognizerDelegate {
    fileprivate func configureActivityView() {
        activityView = NVActivityIndicatorView(frame: recordView.bounds)
        activityView.color = #colorLiteral(red: 0.2156862745, green: 0.5568627451, blue: 0.7921568627, alpha: 1)
        activityView.type = .lineScalePulseOut
        activityView.isHidden = false
        self.recordView.addSubview(activityView)
    }
    
    func startRecording() {
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            if result != nil {
                self.resultLabel.text = result?.bestTranscription.formattedString //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.speechButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechButton.isEnabled = true
        } else {
            speechButton.isEnabled = false
        }
    }
    
    fileprivate func startActivityView() {
        activityView.isHidden = false
        activityView.startAnimating()
    }
    
    fileprivate func stopActivityView() {
        activityView.isHidden = true
        activityView.stopAnimating()
    }
}

