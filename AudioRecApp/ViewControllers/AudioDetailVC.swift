//
//  AudioDetailVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 12.12.2024.
//

import UIKit
import NeonSDK
import AVFoundation
import SnapKit
import FirebaseFirestore
import FirebaseStorage

final class AudioDetailVC: UIViewController, UIDocumentPickerDelegate {
    var audio: AudioModel?
    
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
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    private let updatedAtLabel = UILabel()
    
    var summary: String?
    var speech: String?
    var audioDownloadURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchAudio(audioURL: audio?.audioDownloadURL)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        setupThreeDotMenu()
    }
 
    func setupUI() {
        titleLabel.text = "Audio Details"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }
        
        backButton.setImage(UIImage(named: "btn_back"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(54)
        }
        
        let summaryTitleLabel = UILabel()
        summaryTitleLabel.text = "Summary Keywords"
        summaryTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        view.addSubview(summaryTitleLabel)
        summaryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let summaryLabel = UILabel()
        summaryLabel.text = audio?.summary
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
            make.top.equalTo(summaryLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let speechLabel = UILabel()
        speechLabel.text = audio?.speech
        speechLabel.numberOfLines = 0
        speechLabel.textColor = .black
        speechLabel.font = .systemFont(ofSize: 14)
        view.addSubview(speechLabel)
        speechLabel.snp.makeConstraints { make in
            make.top.equalTo(speechTitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        if let updatedAt = audio?.updatedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            updatedAtLabel.text = dateFormatter.string(from: updatedAt)
        } else {
            updatedAtLabel.text = "Unknown"
        }

        updatedAtLabel.font = .systemFont(ofSize: 12, weight: .light)
        updatedAtLabel.textColor = .gray
        updatedAtLabel.textAlignment = .right
        view.addSubview(updatedAtLabel)
        updatedAtLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
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
        
        setupControlButtons(in: controlBackgroundView)
        
        tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 10
        tagStackView.alignment = .center
        tagStackView.distribution = .equalSpacing
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagStackView)
        NSLayoutConstraint.activate([
            tagStackView.topAnchor.constraint(equalTo: speechLabel.bottomAnchor, constant: 20),
            tagStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tagStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tagStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupControlButtons(in view: UIView) {
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
        view.addSubview(controlsStack)
        controlsStack.snp.makeConstraints { make in
            make.top.equalTo(currentTimeLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }

    func fetchAudio(audioURL: String?) {
        guard let audioURL else {
            print("Audio URL is nil!")
            return
        }
    
        SaveAudioManager.shared.getAudio(audioURL) { data, error in
            if let error {
                print("Error fetching audio: \(error)")
                return
            }
            
            guard let data else {
                print("Audio data is nil!")
                return
            }
            
            print("Audio data fetched successfully")
            self.playAudio(data: data)
        }
    }

    func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            setupTimer()
            print("Audio is playing")
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        slider.value = Float(currentTime / player.duration)
        currentTimeLabel.text = formatTime(currentTime)
        durationLabel.text = formatTime(player.duration)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setupThreeDotMenu() {
        let tagAction = UIAction(title: "Tag", image: .add, handler: { _ in
            self.handleTagAction()
        })
        
        let copyAction = UIAction(title: "Copy", image: .copy ,handler: { _ in
            self.handleCopyAction()
        })
        
        let saveAction = UIAction(title: "Save", image: .save ,handler: { _ in
            self.handleSaveAction()
        })
        
        let shareAction = UIAction(title: "Share", image: .share , handler: { _ in
            self.handleShareAction()
        })
        
        let deleteAction = UIAction(title: "Delete", image: .delete, attributes: .destructive, handler: { _ in
            self.handleDeleteAction()
        })
        
        let menu = UIMenu(title: "", children: [tagAction, copyAction, saveAction, shareAction, deleteAction])
        
        let threeDotButton = UIButton(type: .system)
        threeDotButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        threeDotButton.tintColor = .black
        threeDotButton.menu = menu
        threeDotButton.showsMenuAsPrimaryAction = true
        
        let barButtonItem = UIBarButtonItem(customView: threeDotButton)
        let rightBarButtonItem = UINavigationItem()
        rightBarButtonItem.rightBarButtonItem = barButtonItem
        navigationItem.rightBarButtonItem = barButtonItem

        let buttonWidth: CGFloat = 44
        threeDotButton.frame = CGRect(x: view.frame.width - buttonWidth - 16, y: 60, width: buttonWidth, height: buttonWidth)
        view.addSubview(threeDotButton)
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
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
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

    func saveFile(to location: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let folderURL = documentsDirectory.appendingPathComponent(location)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Klasör oluşturulurken bir hata oluştu: \(error)")
                return
            }
        }
        
        let fileURL = folderURL.appendingPathComponent("audioFile.wav")
        let fileData = "Bu bir örnek dosya verisidir.".data(using: .utf8)!
        
        do {
            try fileData.write(to: fileURL)
            print("Dosya başarıyla kaydedildi: \(fileURL.path)")
        } catch {
            print("Dosya kaydedilemedi: \(error)")
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
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteItem()
            }))
            present(alert, animated: true)
        }

    func deleteItem() {
        guard let audioDownloadURL = audio?.audioDownloadURL else {
            print("Audio URL is missing")
            return
        }
        let storageRef = Storage.storage().reference(forURL: audioDownloadURL)

        storageRef.delete { error in
            if let error = error {
                print("Error deleting file from Firebase Storage: \(error.localizedDescription)")
            } else {
                print("File deleted successfully from Firebase Storage")
                LottieManager.showFullScreenLottie(animation: .custom(name: "deleted"), playOnce: true)
                FirestoreManager.deleteDocument(path: [.collection(name: "Voices"),.document(name: self.audio?.id ?? "")])
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.backButtonTapped()
                }
            }
        }
    }

    @objc func playPauseButtonTapped() {
        if isPlaying {
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            if audioPlayer == nil {
                guard let audioURL = audio?.audioDownloadURL else {
                    print("Audio URL is nil")
                    return
                }
                fetchAudio(audioURL: audioURL)
            }
            
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPlaying.toggle()
    }

    @objc func backButtonTapped() {
        let presentvc = HomeVC()
        present(destinationVC: presentvc, slideDirection: .left)
    }
}
