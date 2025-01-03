import UIKit

class AudioDocCell: UITableViewCell {
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let dateLabel = UILabel()
    let durationLabel = UILabel()
    let thumbnailImageView = UIImageView()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        contentView.addSubview(thumbnailImageView)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        contentView.addSubview(descriptionLabel)

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        contentView.addSubview(dateLabel)
        
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = .gray
        contentView.addSubview(durationLabel)
        
        chevronImageView.tintColor = .lightGray
        contentView.addSubview(chevronImageView)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.top)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(16)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(thumbnailImageView.snp.bottom)
            make.leading.equalTo(titleLabel)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.leading.equalTo(dateLabel.snp.trailing).offset(8)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(20)
        }
    }
}
