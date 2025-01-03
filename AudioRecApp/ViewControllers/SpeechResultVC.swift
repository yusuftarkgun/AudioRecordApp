//
//  SpeechResultVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 7.12.2024.
//

import UIKit
import AVFoundation
import NeonSDK
import SnapKit
import MobileCoreServices
import FirebaseFirestore

final class SpeechResultVC: UIViewController {
    var audio: Data?
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var timer: Timer?
    var selectedColor: UIColor?
    var tagStackView: UIStackView!
    var audioID: String?
    
    private let playPauseButton = UIButton(type: .system)
    private let rewindButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let speedButton = UIButton(type: .system)
    private let slider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let speechTitleLabel = UILabel()
    
    var summary: String?
    var speech: String?
    var audioDownloadURL: String?
    var localAudioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireBase()
        setupUI()
     //   setupAudioPlayer()
        setupThreeDotMenu()
        playAudio()
    }
   
    
    func playAudio() {
        guard let localAudioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: localAudioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error initializing audio player: \(error)")
        }
    }
    
    func fireBase(){
        audioID = UUID().uuidString
        FirestoreManager.setDocument(
            path: [
                .collection(name: "Voices"),
                .document(name: audioID ?? "")
            ],
            fields: [
                "summary": summary ?? "",
                "speech": speech ?? "",
                "audioDownloadURL": audioDownloadURL ?? "",
                "id": audioID ?? ""
            ]
        )
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        let titleLabel = UILabel()
        titleLabel.text = "New Voice"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.centerX.equalToSuperview()
        }
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "btn_back"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(54)
        }
        
        let summaryTitleLabel = UILabel()
        summaryTitleLabel.text = "Summary Keywords"
        summaryTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(summaryTitleLabel)
        summaryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let summaryLabel = UILabel()
        summaryLabel.text = summary
        summaryLabel.numberOfLines = 0
        summaryLabel.textColor = .black
        summaryLabel.font = .systemFont(ofSize: 14)
        view.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryTitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let speechTitleLabel = UILabel()
        speechTitleLabel.text = "Yusuf Tarık Gün"
        speechTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(speechTitleLabel)
        speechTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let speechLabel = UILabel()
        speechLabel.text = speech
        speechLabel.numberOfLines = 0
        speechLabel.font = .systemFont(ofSize: 14)
        view.addSubview(speechLabel)
        speechLabel.snp.makeConstraints { make in
            make.top.equalTo(speechTitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let controlBackgroundView = UIView()
        controlBackgroundView.backgroundColor = .systemGray6
        controlBackgroundView.layer.cornerRadius = 10
        view.addSubview(controlBackgroundView)
        controlBackgroundView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(120)
            
        }
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        controlBackgroundView.addSubview(slider)
        slider.setThumbImage(UIImage(named: "ellipse"), for: .normal)
        slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = .systemFont(ofSize: 12)
        controlBackgroundView.addSubview(currentTimeLabel)
        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.leading.equalTo(slider.snp.leading)
        }
        
        durationLabel.text = "00:00"
        durationLabel.font = .systemFont(ofSize: 12)
        controlBackgroundView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.trailing.equalTo(slider.snp.trailing)
        }
        
        rewindButton.setImage(UIImage(systemName: "gobackward.5"), for: .normal)
        rewindButton.tintColor = .black
        rewindButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .black
        playPauseButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        
        forwardButton.setImage(UIImage(systemName: "goforward.5"), for: .normal)
        forwardButton.tintColor = .black
        forwardButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        speedButton.setTitle("1x", for: .normal)
        speedButton.tintColor = .black
        speedButton.titleLabel?.font = .systemFont(ofSize: 12)
        
        let controlsStack = UIStackView(arrangedSubviews: [rewindButton, playPauseButton, forwardButton, speedButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 20
        controlsStack.alignment = .center
        controlBackgroundView.addSubview(controlsStack)
        controlsStack.snp.makeConstraints { make in
            make.top.equalTo(currentTimeLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 10
        tagStackView.alignment = .center
        tagStackView.distribution = .equalSpacing
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagStackView)
        
        NSLayoutConstraint.activate([
            tagStackView.topAnchor.constraint(equalTo: speechTitleLabel.bottomAnchor, constant: 20),
            tagStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tagStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tagStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupAudioPlayer() {
        guard let audio = audio else {
            print("Audio data is missing.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: audio)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            updateDurationLabel()
            isPlaying = true
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        timer?.invalidate()
    }
    
    func updateDurationLabel() {
        guard let audioPlayer = audioPlayer else { return }
        let duration = audioPlayer.duration
        durationLabel.text = formatTime(duration)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func sliderValueChanged() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.currentTime = Double(slider.value) * audioPlayer.duration
        updateCurrentTimeLabel()
    }
    
    @objc func togglePlayPause() {
        guard let audioPlayer = audioPlayer else { return }
        
        if isPlaying {
            audioPlayer.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startTimer()
        }
        
        isPlaying.toggle()
    }
    
    @objc func rewind() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.currentTime = max(audioPlayer.currentTime - 5, 0)
        updateCurrentTimeLabel()
    }
    
    @objc func forward() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.currentTime = min(audioPlayer.currentTime + 5, audioPlayer.duration)
        updateCurrentTimeLabel()
    }
    
    @objc func changeSpeed() {
        guard let audioPlayer = audioPlayer else { return }
        if audioPlayer.rate == 1.0 {
            audioPlayer.rate = 2.0
            speedButton.setTitle("2x", for: .normal)
        } else {
            audioPlayer.rate = 1.0
            speedButton.setTitle("1x", for: .normal)
        }
        audioPlayer.enableRate = true
    }
    
    func updateCurrentTimeLabel() {
        guard let audioPlayer = audioPlayer else { return }
        currentTimeLabel.text = formatTime(audioPlayer.currentTime)
        slider.value = Float(audioPlayer.currentTime / audioPlayer.duration)
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateCurrentTimeLabel()
        }
    }
    
    private func setupThreeDotMenu() {
        let tagAction = UIAction(title: "Tag", image: .add  , handler: { _ in
            self.handleTagAction()
        })
        
        let copyAction = UIAction(title: "Copy", image: .copy ,handler: { _ in
            self.handleCopyAction()
        })
        
        let SaveAction = UIAction(title: "Save", image: .save ,handler: { _ in
            self.handleSaveAction()
        })
        
        let shareAction = UIAction(title: "Share",image: .share  , handler: { _ in
            self.handleShareAction()
        })
        
        let deleteAction = UIAction(title: "Delete", image: .delete  ,attributes: .destructive, handler: { _ in
            self.handleDeleteAction()
        })
        
        let menu = UIMenu(title: "", children: [tagAction, copyAction, SaveAction, shareAction, deleteAction])
        
        let threeDotButton = UIButton(type: .system)
        threeDotButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        threeDotButton.tintColor = .black
        threeDotButton.menu = menu
        threeDotButton.showsMenuAsPrimaryAction = true
        
        let barButton = UIBarButtonItem(customView: threeDotButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func handleTagAction() {
        let alert = UIAlertController(title: "Tag", message: "Enter a tag and choose a color", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter tag"
            textField.autocapitalizationType = .sentences
        }
        
        let colorPickerAction = UIAlertAction(title: "Choose Color", style: .default) { _ in
            let colorPickerAlert = UIAlertController(title: "Choose a Color", message: nil, preferredStyle: .alert)
            
            let colors: [UIColor] = [.red, .green, .blue, .orange, .purple, .yellow]
            let colorNames: [String] = ["Red", "Green", "Blue", "Orange", "Purple", "Yellow"]
            
            for (index, color) in colors.enumerated() {
                colorPickerAlert.addAction(UIAlertAction(title: colorNames[index], style: .default) { _ in
                    self.selectedColor = color
                })
            }
            
            colorPickerAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(colorPickerAlert, animated: true)
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            guard let textField = alert?.textFields?.first, let tagText = textField.text, !tagText.isEmpty else {
                return
            }
            
            let tagLabel = UILabel()
            tagLabel.text = tagText
            tagLabel.textColor = .white
            tagLabel.font = .systemFont(ofSize: 14)
            tagLabel.backgroundColor = self.selectedColor ?? .gray
            tagLabel.layer.cornerRadius = 10
            tagLabel.layer.masksToBounds = true
            tagLabel.padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            
            self.tagStackView.addArrangedSubview(tagLabel)
        }
        
        alert.addAction(colorPickerAction)
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleCopyAction() {
        
        UIPasteboard.general.string = summary
        print("Content copied to clipboard")
        LottieManager.showFullScreenLottie(animation: .custom (name: "coppied"), color: .black ,playOnce: true)
    }
    
    func handleSaveAction() {
        let alert = UIAlertController(title: "Save Location", message: "Please enter the location to save the file", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter folder name or location"
            textField.autocapitalizationType = .sentences
        }
        
        _ = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            guard let textField = alert?.textFields?.first, let location = textField.text, !location.isEmpty else {
                print("Location not provided.")
                return
            }
            
            self.presentDocumentPicker(for: location)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentDocumentPicker(for location: String) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [URL(fileURLWithPath: location)], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func saveFile(to location: String, fileName: String = "audioFile.wav", completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let folderURL = documentsDirectory.appendingPathComponent(location)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Folder created: \(folderURL.path)")
            } catch {
                print("Error creating folder: \(error)")
                completion(false)
                return
            }
        }
        
        let fileURL = folderURL.appendingPathComponent(fileName)
        let fileData = "This is sample file data.".data(using: .utf8)!
        
        do {
            try fileData.write(to: fileURL)
            print("File successfully saved at: \(fileURL.path)")
            completion(true)
        } catch {
            print("Error saving file: \(error)")
            completion(false)
        }
    }
    
    func handleShareAction() {
        print("Share option selected")
        let activityVC = UIActivityViewController(activityItems: [summary as Any], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    func handleDeleteAction() {
        print("Delete option selected")
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem()
        }))
        present(alert, animated: true)
    }
    
    func deleteItem() {
        guard let audioID = audioID else { return }
        let firestore = Firestore.firestore()
        firestore.collection("Voices").document(audioID).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Item deleted successfully")
                LottieManager.showFullScreenLottie(animation: .custom(name: "deleted"), playOnce: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigateToSpeechRecognitionVC()
                }
            }
        }
    }
    
    func navigateToSpeechRecognitionVC() {
        let speechVC = SpeechRecognitionVC()
        present(destinationVC: speechVC, slideDirection: .right)
    }
}

extension SpeechResultVC: AVAudioPlayerDelegate {
        
    @objc private func backButtonTapped() {
        navigateToSpeechRecognitionVC()
    }
}

extension SpeechResultVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            let folderPath = selectedURL.deletingLastPathComponent().path
            print("Selected folder path: \(folderPath)")
            //saveFile(to: folderPath, completion: true)
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("File selection was canceled.")
    }
}

extension UIView {
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        set {
            self.frame = self.frame.inset(by: newValue)
        }
    }
}
