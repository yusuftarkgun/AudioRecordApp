import UIKit
import NeonSDK

final class Onboarding1VC: NeonOnboardingController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureButton(
            title: "Next",
            titleColor: .white,
            font: Font.custom(size: 21, fontWeight: .Regular),
            cornerRadious: 17,
            height: 60,
            horizontalPadding: 40,
            bottomPadding: 20,
            backgroundColor: UIColor(red: 0.325, green: 0.373, blue: 1, alpha: 1),
            borderColor: nil,
            borderWidth: nil
        )
    
        self.configureBackground(
            type: .halfBackgroundImage(
                backgroundColor: .white,
                offset: 50,
                isFaded: false
            )
        )

        self.configurePageControl(
            type: .V2,
            currentPageTintColor: .black,
            tintColor: .gray,
            radius: 4,
            padding: 8
        )

        self.configureText(
            titleColor: .black,
            titleFont: Font.custom(size: 30, fontWeight: .Bold),
            subtitleColor: .black,
            subtitleFont: Font.custom(size: 18, fontWeight: .Medium)
        )

        self.addPage(
            title: "Make Records Easily",
            subtitle: "Transform the spoken word into polished text effortlessly with AudioDoc.",
            image: UIImage(named: "onboarding1") ?? UIImage(ciImage: .gray)
        )

        self.addPage(
            title: "Voice to Text",
            subtitle: "The sounds you record can be turned into meaningful text. You can add photos and customize them.",
            image: UIImage(named: "onboarding2") ?? UIImage(ciImage: .gray)
        )

        self.addPage(
            title: "Records in Memory",
            subtitle: "All your projects are stored in memory, and you can change the text styles and regain access to them at any time.",
            image: UIImage(named: "onboarding3") ?? UIImage(ciImage: .gray)
        )
    }
    
    override func onboardingCompleted() {
        let paywallVC = PaywallVC()
        paywallVC.modalPresentationStyle = .fullScreen
        present(paywallVC, animated: true, completion: nil)
    }
}

