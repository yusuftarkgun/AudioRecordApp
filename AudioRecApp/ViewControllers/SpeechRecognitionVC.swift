//
//  RecordVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 5.12.2024.
//

import UIKit
import Speech
import NeonSDK
import Lottie

final class SpeechRecognitionVC: UIViewController {

    private var waveImageView: LottieAnimationView!
    private var progress: CGFloat = 0.0
    private let textView = UITextView()
    private let recordButton = UIButton(type: .system)
    private let pauseResumeButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let timeLabel = UILabel()
    private let backButton = UIButton()
    private let pressToStartLabel = UILabel()
    
    private var languageButton: UIButton!
    private let languageOptions = ["Spanish", "Turkish", "Italian"]
    private var selectedLanguage: String = "English" 
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioDownloadURL: String?
    private var audio: Data?
    private var audioPath: String?
    private var isPaused = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0.0
    
    private let openAIService = OpenAIService.shared
    private var localAudioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
        setupLanguagePicker()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Record"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }

        backButton.setImage(UIImage(named: "btn_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.left.equalToSuperview().offset(16)
        }

        timeLabel.text = "00:00"
        timeLabel.font = .systemFont(ofSize: 20, weight: .bold)
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        timeLabel.layer.cornerRadius = 8
        timeLabel.layer.masksToBounds = true
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

        waveImageView = LottieAnimationView(name: "wave")
        waveImageView.contentMode = .scaleAspectFit
        view.addSubview(waveImageView)
        waveImageView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(100)
        }

        recordButton.setImage(UIImage(named: "microphoneBlue"), for: .normal)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(waveImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        pressToStartLabel.text = "Press to Start"
        pressToStartLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pressToStartLabel.textAlignment = .center
        pressToStartLabel.textColor = .black
        view.addSubview(pressToStartLabel)
        pressToStartLabel.snp.makeConstraints { make in
            make.bottom.equalTo(recordButton.snp.top).offset(-8)
            make.centerX.equalToSuperview()
        }

        pauseResumeButton.setImage(UIImage(named: "resumee"), for: .normal)
        pauseResumeButton.isHidden = true
        pauseResumeButton.addTarget(self, action: #selector(pauseOrResumeRecording), for: .touchUpInside)
        view.addSubview(pauseResumeButton)
        pauseResumeButton.snp.makeConstraints { make in
            make.centerY.equalTo(recordButton)
            make.right.equalTo(recordButton.snp.left).offset(-40)
            make.width.height.equalTo(60)
        }

        stopButton.setImage(UIImage(named: "stopbutton"), for: .normal)
        stopButton.isHidden = true
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        view.addSubview(stopButton)
        stopButton.snp.makeConstraints { make in
            make.centerY.equalTo(recordButton)
            make.left.equalTo(recordButton.snp.right).offset(40)
            make.width.height.equalTo(60)
        }
    }

    private func setupLanguagePicker() {
        languageButton = UIButton(type: .system)
        languageButton.setTitle("Select Language", for: .normal)
        languageButton.addTarget(self, action: #selector(showLanguagePicker), for: .touchUpInside)
        view.addSubview(languageButton)
        languageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    @objc private func showLanguagePicker() {
        let alert = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        
        for language in languageOptions {
            alert.addAction(UIAlertAction(title: language, style: .default, handler: { _ in
                self.selectedLanguage = language
                self.updateSpeechRecognizerLanguage()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func updateSpeechRecognizerLanguage() {
        if selectedLanguage == "English" {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        } else {
            switch selectedLanguage {
            case "Spanish":
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
            case "Turkish":
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR"))
            case "Italian":
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))
            default:
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            }
        }

        print("Speech recognizer updated to \(selectedLanguage)")
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                case .denied, .restricted, .notDetermined:
                    self.recordButton.isEnabled = false
                    print("Speech recognition authorization denied.")
                @unknown default:
                    fatalError("Unknown authorization status")
                }
            }
        }
    }

    private func startLoadingAnimation() {
        waveImageView.play(fromProgress: progress, toProgress: 1.0, loopMode: .loop) { [weak self] (finished) in
            if finished {
                print("Animasyon tamamlandı.")
            }
        }
    }
    
    @objc private func startRecording() {
        if speechRecognizer == nil {
                  updateSpeechRecognizerLanguage()
              }
        guard !audioEngine.isRunning else { return }
        try? startSpeechRecognition()
        
        recordButton.isHidden = true
        pauseResumeButton.isHidden = false
        stopButton.isHidden = false
        pressToStartLabel.isHidden = true
        
        startTimer()
        startLoadingAnimation()
    }
    
    @objc private func pauseOrResumeRecording() {
        if isPaused {
            startTimer()
            pauseResumeButton.setImage(UIImage(named: "resumebutton"), for: .normal)
            try? audioEngine.start()
            waveImageView.play(fromProgress: progress, toProgress: 1.0, loopMode: .none) { [weak self] (finished) in
                if finished {
                    self?.progress = 1.0
                    print("Wave animation resumed")
                }
            }
            isPaused = false
        } else {
            stopTimer()
            pauseResumeButton.setImage(UIImage(named: "stopbutton"), for: .normal)
            audioEngine.pause()
            waveImageView.stop()
            isPaused = true
        }
    }

    @objc private func stopRecording() {
        guard audioEngine.isRunning else { return } 
        
        stopAudioEngine()
        recordButton.isHidden = false
        pauseResumeButton.isHidden = true
        stopButton.isHidden = true
        pressToStartLabel.isHidden = false
        
        stopTimer()
        
        waveImageView.stop()
    }

    private func startSpeechRecognition() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create request") }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        let uuid = UUID().uuidString
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioFileURL = documentsPath.appendingPathComponent("\(uuid).wav")
        
        var settings = recordingFormat.settings
        settings[AVFormatIDKey] = kAudioFormatLinearPCM
        settings[AVLinearPCMBitDepthKey] = 16
        settings[AVLinearPCMIsBigEndianKey] = false
        settings[AVLinearPCMIsFloatKey] = false

        let audioFile = try AVAudioFile(forWriting: audioFileURL, settings: settings)
        localAudioURL = audioFileURL
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
            }
            if error != nil || result?.isFinal == true {
                LottieManager.showFullScreenLottie(animation: .loadingCircle)
                self.stopRecording()
                self.uploadAudioToFirebase(audioFileURL: audioFileURL)
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
            
            do {
                try audioFile.write(from: buffer)
            } catch {
                print("Audio file write error: \(error.localizedDescription)")
            }
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        print("Recording started. File will be saved at: \(audioFileURL)")
    }
    
    private func uploadAudioToFirebase(audioFileURL: URL) {
        if let audioData = try? Data(contentsOf: audioFileURL) {
            self.audio = audioData
            SaveAudioManager.shared.uploadAudio(audioData) { downloadURL in
                if let downloadURL = downloadURL {
                    print("Uploaded audio URL: \(downloadURL)")
                    self.audioDownloadURL = downloadURL
                    self.getSummary(from: self.textView.text)
                } else {
                    print("Failed to upload audio.")
                }
            }
        } else {
            print("Failed to convert audio file to Data.")
        }
    }

    private func getSummary(from text: String) {
        openAIService.getSummary(from: text) { summary in
            DispatchQueue.main.async {
                LottieManager.removeFullScreenLottie()
                
                let vc = SpeechResultVC()
                vc.summary = summary
                vc.speech = self.textView.text
                vc.audioDownloadURL = self.audioDownloadURL
                vc.audio = self.audio
                vc.localAudioURL = self.localAudioURL

                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            }
        }
    }

    private func startTimer() {
        if timer != nil { return }
        
        if startTime == nil {
            startTime = Date()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        if let startTime = startTime {
            elapsedTime += Date().timeIntervalSince(startTime)
        }
        startTime = nil
    }
    @objc private func updateTime() {
        guard let startTime = startTime else { return }
        let totalElapsedTime = elapsedTime + Date().timeIntervalSince(startTime)
        
        let minutes = Int(totalElapsedTime) / 60
        let seconds = Int(totalElapsedTime) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func stopAudioEngine() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    @objc private func backButtonTapped() {
        present(destinationVC: HomeVC(), slideDirection: .left)
    }
}
