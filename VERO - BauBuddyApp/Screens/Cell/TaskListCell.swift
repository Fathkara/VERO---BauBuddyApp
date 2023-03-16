//
//  TaskListCell.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import UIKit
import SnapKit
import SwiftHEXColors

class TaskListCell: UITableViewCell {
    
    //MARK: UI
    var titleLabel = UILabel()
    var taskLabel = UILabel()
    var descriptLabel = UILabel()
    
    enum Identifier: String {
        case path = "Cell"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private function
    private func createCell() {
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        taskLabel.textColor = .black
        taskLabel.numberOfLines = 0
        contentView.addSubview(taskLabel)
        taskLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(10)
        }
        descriptLabel.textColor = .black
        descriptLabel.numberOfLines = 0
        descriptLabel.textAlignment = .left
        descriptLabel.font = UIFont.systemFont(ofSize: 10)
        descriptLabel.layer.masksToBounds = true
        contentView.addSubview(descriptLabel)
        descriptLabel.snp.makeConstraints { make in
            make.top.equalTo(taskLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-8)
        }
    }
    
    func saveData(data: Task) {
        titleLabel.text = data.title
        taskLabel.text = data.task
        descriptLabel.text = data.descriptionTask
    }

}
