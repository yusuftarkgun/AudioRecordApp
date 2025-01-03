//
//  AppDelegate.swift
//  AudioRecApp
//  Created by Yusuf Tarık Gün on 3.12.2024.
//
import Firebase
import UIKit
import NeonSDK
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        Font.configureFonts(font: .Inter)
        
        Neon.configure(
            window: &window,
            onboardingVC: Onboarding1VC(),
            paywallVC: PaywallVC(),
            homeVC: HomeVC())
        
        let onboardingVC = Onboarding1VC()
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
        
        return true
    }
}



