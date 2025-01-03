//
//  PaywallVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 3.12.2024.
//

import UIKit
import NeonSDK
import SnapKit

final class PaywallVC: UIViewController {
    
    var page: String?
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let featureLabel1 = UILabel()
    let featureLabel2 = UILabel()
    let featureLabel3 = UILabel()
    let featureLabel4 = UILabel()
    
    let boxView1 = UIView()
    let boxView2 = UIView()
    let boxView3 = UIView()
    let boxView4 = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addTextImage()
        setupFeatureLabels()
        setupBoxViews()
        addPaymentOptions()
        addContinueButton()
        addTermsGroup()
        addCloseButton()
    }
    
    func addTextImage() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "text")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(120)
        }
    }
    
    func setupFeatureLabels() {
        let features = [
            ("Fast-Track Time Experience", 334),
            ("Save in Memory Seamlessly", 438),
            ("Unlimited Recording Duration", 283),
            ("Different Styles for Record Transcriptions", 386)
        ]
        
        let featureLabels = [featureLabel1, featureLabel2, featureLabel3, featureLabel4]
        
        for (index, (text, topOffset)) in features.enumerated() {
            let label = featureLabels[index]
            label.textColor = .black
            label.font = UIFont(name: "Inter-SemiBold", size: 16)
            label.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    .kern: -0.41,
                    .paragraphStyle: createParagraphStyle(lineHeight: 22)
                ]
            )
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(74)
                make.top.equalToSuperview().offset(topOffset)
                make.width.equalTo(300)
                make.height.equalTo(22)
            }
        }
    }
    
    func setupBoxViews() {
        let icons = [
            ("img_paywallIcon1", 281),
            ("img_paywallIcon2", 332),
            ("img_paywallIcon3", 388),
            ("img_paywallIcon4", 439)
        ]
        
        let boxViews = [boxView1, boxView2, boxView3, boxView4]
        
        for (index, (imageName, topOffset)) in icons.enumerated() {
            let boxView = boxViews[index]
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFit
            boxView.addSubview(imageView)
            view.addSubview(boxView)
            
            boxView.snp.makeConstraints { make in
                make.width.height.equalTo(30)
                make.leading.equalToSuperview().offset(42)
                make.top.equalToSuperview().offset(topOffset)
            }
            
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func addPaymentOptions() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "paymentOptions")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(500)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
    }
    
    func addTermsGroup() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "termsGroup")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(900)
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
    }
    
    func addContinueButton() {
        let button = UIButton()
        button.layer.backgroundColor = UIColor(red: 0.325, green: 0.373, blue: 1, alpha: 1).cgColor
        button.layer.cornerRadius = 17
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(717)
            make.width.equalTo(330)
            make.height.equalTo(58)
        }
    }
    
    func addCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    @objc func buttonTapped() {
        print("Button tapped")
        let destinationVC = HomeVC()
        present(destinationVC: destinationVC, slideDirection: .right)
    }
    
    @objc func closeButtonTapped() {
        if let page, page == "Settings" {
            self.dismiss(animated: true)
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let homeVC = HomeVC()
                let navigationController = UINavigationController(rootViewController: homeVC)
                appDelegate.window?.rootViewController = navigationController
            }
        }
    }
    
    func createParagraphStyle(lineHeight: CGFloat) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeight / 22
        return paragraphStyle
    }
    
    @objc func dismissPaywall() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
