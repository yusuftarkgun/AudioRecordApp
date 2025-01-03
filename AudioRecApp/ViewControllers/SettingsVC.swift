//
//  SettingsVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 4.12.2024.
//

import UIKit
import SnapKit
import NeonSDK
import SafariServices
import StoreKit

final class SettingsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    private func setupUI() {
        let gradientView = NeonBlurView()
        gradientView.colorTint = .blue
        gradientView.colorTintAlpha = 0.8
        gradientView.blurRadius = 10
        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        gradientView.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }
        
        let smallButton = NeonBouncingButton()
        smallButton.setImage(UIImage(named: "getPremium"), for: .normal)
        gradientView.contentView.addSubview(smallButton)

        smallButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.width.equalTo(350)
            make.height.equalTo(150)
        }

        smallButton.addTarget(self, action: #selector(goToPaywall), for: .touchUpInside)


        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 18
        buttonStack.alignment = .fill
        buttonStack.distribution = .fill

        let options = [
            ("Rate Us", UIImage(named: "rateUs")!, UIImage(named: "arrow")),
            ("Contact Us", UIImage(named: "contactUs")!, UIImage(named: "arrow")),
            ("Privacy Policy", UIImage(named: "privacyPolicy")!, UIImage(named: "arrow")),
            ("Terms of Use", UIImage(named: "termsofUse")!, UIImage(named: "arrow")),
            ("Restore Purchase", UIImage(named: "Restore")!, UIImage(named: "arrow")),
            ("Logout", UIImage(named: "logout")!, UIImage(named: ""))
        ]
        
        for (title, leftImage, rightImage) in options {
            let button = UIButton(type: .system)
            
            button.setTitle(title, for: .normal)
            button.setImage(leftImage, for: .normal)
            button.tintColor = .black
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.contentHorizontalAlignment = .left
            
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

            let rightArrowStack = UIStackView()
            rightArrowStack.axis = .vertical
            rightArrowStack.spacing = 40
            rightArrowStack.alignment = .center

            for _ in 0..<1 {
                let arrowImageView = UIImageView(image: rightImage)
                rightArrowStack.addArrangedSubview(arrowImageView)
            }
            
            button.addSubview(rightArrowStack)
            rightArrowStack.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().inset(10)
                make.width.equalTo(20)
            }
            
            if title == "Logout" {
                       button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                   }
            
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.tag = options.firstIndex(where: { $0.0 == title }) ?? 0
            
            button.snp.makeConstraints { make in
                make.height.equalTo(60)
            }
            
            buttonStack.addArrangedSubview(button)
        }
        
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(gradientView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }
    }

        @objc private func buttonTapped(_ sender: UIButton) {
            switch sender.tag {
            case 0:
                print("Rate Us Tapped")
                let destinationVC = RateUsVC()
                present(destinationVC: destinationVC, slideDirection: .right)
            case 1:
                print("Contact Us Tapped")
                let destinationVC = ContactUsVC()
                present(destinationVC: destinationVC, slideDirection: .right)
            case 2:
                print("Privacy Policy Tapped")
                openWebPage(url: "https://www.neonapps.co/privacy-policy](https://www.neonapps.co/privacy-policy")
            case 3:
                print("Terms of Use Tapped")
                openWebPage(url: "https://www.neonapps.co/terms-of-use](https://www.neonapps.co/terms-of-use")
            case 4:
                print("Restore Purchase Tapped")
                SKPaymentQueue.default().restoreCompletedTransactions()

                restorePurchases()
            case 5:
                print("Logout Tapped")
                logoutUser()
            default:
                break
            }
        }
    
    private func logoutUser() {
        print("User logged out")

        let destinationVC = Onboarding1VC()
        present(destinationVC: destinationVC, slideDirection: .right)
    }
    
    private func openWebPage(url: String) {
        guard let url = URL(string: url) else {
            print("Geçersiz URL")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    private func restorePurchases() {
           print("Restoring purchases...")
           SKPaymentQueue.default().restoreCompletedTransactions()
       }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions {
                switch transaction.transactionState {
                case .restored:
                    print("Purchase restored: \(transaction.payment.productIdentifier)")
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .failed:
                    if let error = transaction.error {
                        print("Restore failed: \(error.localizedDescription)")
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                default:
                    break
                }
            }
        }

        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            print("All purchases have been restored.")
        }

        func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
            print("Failed to restore purchases: \(error.localizedDescription)")
        }
    
    @objc func goToPaywall() {
        let paywallVC = PaywallVC()
        paywallVC.page = "Settings"
        present(destinationVC: paywallVC, slideDirection: .right)
    }

}

