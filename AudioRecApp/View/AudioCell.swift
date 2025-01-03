//
//  AudioCell.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 9.12.2024.
//

import UIKit
import SnapKit

final class AudioCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let myView = UIView()
        contentView.addSubview(myView)
        myView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        myView.layer.cornerRadius = 15

        myView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(5)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
        
        let image = UIImage(named: "avatar")
        avatarImageView.image = image
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.clipsToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black

        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 2

        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray

        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .gray

        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(arrowImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-8)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(12)
            make.height.equalTo(20)
        }
    }

    func configure(with model: AudioModel) {
        titleLabel.text = model.summary ?? "No Title"
        descriptionLabel.text = model.speech ?? "No Description"
        dateLabel.text = formatDate(model.updatedAt)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

