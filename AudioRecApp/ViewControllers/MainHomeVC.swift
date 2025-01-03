//
//  MainHomeVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 4.12.2024.
//

import NeonSDK
import UIKit


final class MainHomeVC: UIViewController {

    private var timelineData: [String] = []
    let titleLabel = UILabel()
    var floatingButton: UIButton?
    var audios: [AudioModel]?

    override func viewDidLoad() {
        super.viewDidLoad()
        headTitle()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAudios()
        if floatingButton == nil {
            addButon()
        }
    }
    
    private func setupUI() {
        
        if let audios, audios.isEmpty {
            showEmptyState()
        } else {
            showTimeline()
    
        }
    }
        
    private func showEmptyState() {
        let emptyStateView = UIView()
        emptyStateView.backgroundColor = .clear
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        let emptyImageView = UIImageView(image: UIImage(named: "microphone"))
        emptyImageView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
        }

        let emptyLabel = UILabel()
        emptyLabel.text = "Nothing Saved in Timeline"
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = .gray
        emptyStateView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    private func showTimeline() {
        let timelineStack = UIStackView()
        timelineStack.axis = .vertical
        timelineStack.spacing = 15
        timelineStack.alignment = .fill
        timelineStack.distribution = .fill
        view.addSubview(timelineStack)
        timelineStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
            
        }
        for data in timelineData {
            let timelineItem = UILabel()
            timelineItem.text = data
            timelineItem.font = UIFont.systemFont(ofSize: 18)
            timelineItem.textColor = .black
            timelineStack.addArrangedSubview(timelineItem)
        }
    }

    func headTitle() {
        let view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 28, height: 31)
        view.textColor = UIColor(red: 0.004, green: 0.004, blue: 0.004, alpha: 1)
        view.font = UIFont(name: "Inter-SemiBold", size: 26)
        view.text = "AudioDoc"
        
        let parent = self.view!
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 128).isActive = true
        view.heightAnchor.constraint(equalToConstant: 31).isActive = true
        view.centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: -7).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 63).isActive = true
    }

    func addButon() {
        let button = UIButton(type: .custom)
        let buttonSize: CGFloat = 60
        button.frame = CGRect(x: self.view.frame.width - buttonSize - 20,
                              y: self.view.frame.height - buttonSize - 100,
                              width: buttonSize,
                              height: buttonSize)

        button.layer.cornerRadius = buttonSize / 2
        button.clipsToBounds = true

        if let buttonImage = UIImage(named: "button") {
            button.setBackgroundImage(buttonImage, for: .normal)
        }

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.view.addSubview(button)

        floatingButton = button
    }
    
    func fetchAudios() {
        self.audios = []
        FirestoreManager.getDocuments(path: [.collection(name: "Voices")], objectType: AudioModel.self) { object in
            if let audio = object as? AudioModel{
                self.audios?.append(audio)
            }
        }
    }

    @objc func buttonTapped() {
        let destinationVC = SpeechRecognitionVC()
        present(destinationVC: destinationVC, slideDirection: .right)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        floatingButton?.removeFromSuperview()
        floatingButton = nil
    }
}

    
    

