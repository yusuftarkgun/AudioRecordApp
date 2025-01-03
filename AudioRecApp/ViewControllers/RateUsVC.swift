//
//  RateUsVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 6.12.2024.
//

import UIKit
import StoreKit

class RateUsVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let rateButton = UIButton()
    private let laterButton = UIButton()
    private let backButtonn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Rate Us"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        
        messageLabel.text = "Please rate your experience with us."
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        rateButton.setTitle("Rate Now", for: .normal)
        rateButton.backgroundColor = .systemBlue
        rateButton.layer.cornerRadius = 10
        rateButton.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
        view.addSubview(rateButton)
        
        rateButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        laterButton.setTitle("Remind Me Later", for: .normal)
        laterButton.backgroundColor = .lightGray
        laterButton.layer.cornerRadius = 10
        laterButton.addTarget(self, action: #selector(laterButtonTapped), for: .touchUpInside)
        view.addSubview(laterButton)
        
        laterButton.snp.makeConstraints { make in
            make.top.equalTo(rateButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        backButtonn.setImage(UIImage(named: "btn_back"), for: .normal)
        backButtonn.addTarget(self, action: #selector(backButtonnTapped), for: .touchUpInside)
        view.addSubview(backButtonn)
        
        backButtonn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.left.equalToSuperview().offset(16)
        }
    }

    @objc private func rateButtonTapped() {
        if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id<YOUR_APP_ID>") {
            if UIApplication.shared.canOpenURL(appStoreURL) {
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
    
    @objc private func laterButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func backButtonnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
