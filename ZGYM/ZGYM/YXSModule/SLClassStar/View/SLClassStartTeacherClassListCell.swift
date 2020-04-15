//
//  SLClassStartTeacherClassListCell.swift
//  ZGYM
//
//  Created by zgjy_mac on 2019/12/3.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit
import NightNight

class SLClassStartTeacherClassListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.mixedBackgroundColor = MixedColor(normal: UIColor.yxs_hexToAdecimalColor(hex: "#F2F5F9"), night: kNightBackgroundColor)
        contentView.addSubview(bgView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(numberLabel)
        bgView.addSubview(memberLabel)
        bgView.addSubview(arrowImage)
        bgView.addSubview(commentLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.right.left.top.equalTo(0)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16.5)
            make.top.equalTo(17)
            make.right.equalTo(-120)
        }
        numberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp_bottom).offset(9.5)
        }
        memberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(numberLabel.snp_right).offset(20.5)
            make.top.equalTo(nameLabel.snp_bottom).offset(9.5)
        }
        commentLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImage.snp_left).offset(-22)
            make.height.equalTo(19)
            make.centerY.equalTo(self)
        }
        arrowImage.snp.makeConstraints { (make) in
            make.right.equalTo(-14.5)
            make.size.equalTo(CGSize.init(width: 13.4, height: 13.4))
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model:SLClassStartClassModel!
    func yxs_setCellModel(_ model: SLClassStartClassModel){
        self.model = model
        nameLabel.text = model.className
        numberLabel.text = "班级号：\(model.classNo ?? "")"
        memberLabel.text = "成员：\(model.classChildrenSum ?? 0)"
        
        commentLabel.text = "\(model.dateText): \(model.score ?? 0)\(model.stageType == .KINDERGARTEN ? "朵" : "")"
        if model.score ?? 0 >= 0{
            commentLabel.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#E1EBFE")
            commentLabel.textColor = kBlueColor
        }else{
            commentLabel.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#F4E2DF")
            commentLabel.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#E8534C")
        }
    }
    // MARK: -getter&setter
    
    lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.mixedBackgroundColor = MixedColor(normal: UIColor.white, night: kNightForegroundColor)
        return bgView
    }()
    
    lazy var nameLabel: YXSLabel = {
        let label = YXSLabel()
        label.font = kTextMainBodyFont
        label.mixedTextColor = MixedColor(normal: kTextMainBodyColor, night: kNight898F9A)
        return label
    }()
    
    lazy var numberLabel: YXSLabel = {
        let label = YXSLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#898F9A")
        return label
    }()
    
    lazy var memberLabel: YXSLabel = {
        let label = YXSLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#898F9A")
        return label
    }()
    
    lazy var arrowImage: UIImageView = {
        let arrowImage = UIImageView.init(image: UIImage.init(named: "arrow_gray"))
        return arrowImage
    }()
    
    lazy var commentLabel: YXSPaddingLabel = {
        let label = YXSPaddingLabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textInsets = UIEdgeInsets.init(top: 0, left: 9.5, bottom: 0, right: 9.5)
        label.cornerRadius = 9.5
        label.clipsToBounds = true
        return label
    }()
}