//
//  HomeVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 3.12.2024.
//

import UIKit

final class HomeVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        
    }
    private func setupUI(){
        let mainHomeVC = MainHomeVC()
        mainHomeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let savedVC = SavedVC()
        savedVC.tabBarItem = UITabBarItem(title: "Saved", image: UIImage(systemName: "bookmark"), tag: 1)
        
        let settingsVC = SettingsVC()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)
        
        viewControllers = [mainHomeVC,savedVC, settingsVC]
        tabBar.tintColor = .black
    }
    
}

