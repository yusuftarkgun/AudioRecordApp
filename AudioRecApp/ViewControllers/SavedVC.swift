//
//  SavedVC.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 4.12.2024.
//

import UIKit
import NeonSDK

final class SavedVC: UIViewController {
    private var audioModels: [AudioModel] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(AudioCell.self, forCellReuseIdentifier: "AudioCell")

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

    private func fetchData() {
        audioModels = []
        FirestoreManager.getDocuments(path: [.collection(name: "Voices")], objectType: AudioModel.self) { object in
            if let audio = object as? AudioModel {
                self.audioModels.append(audio)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
extension SavedVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioCell
        let model = audioModels[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = audioModels[indexPath.row]
        let destinationVC = AudioDetailVC()
        destinationVC.audio = audio
        self.present(destinationVC: destinationVC, slideDirection: .right)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }

}
