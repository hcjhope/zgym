//
//  YXSClassStarTeacherPublishView.swift
//  ZGYM
//
//  Created by zgjy_mac on 2019/12/5.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit
import NightNight

let kYXSClassStarTeacherPublishViewReloadDataEvent = "YXSClassStarTeacherPublishViewReloadDataEvent"
let kYXSClassStarTeacherPublishViewUpdateCommentButtonEvent = "YXSClassStarTeacherPublishViewUpdateCommentButtonEvent"
let kYXSClassStarTeacherPublishViewDoCommentEvent = "YXSClassStarTeacherPublishViewDoCommentEvent"
class YXSClassStarTeacherPublishView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topView)
        topView.addSubview(topDropView)
        topView.addSubview(commentButton)
        addSubview(collectionView)
        topView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(45)
        }
        topDropView.snp.makeConstraints { (make) in
            make.left.equalTo(16.5)
            make.height.equalTo(20)
            make.centerY.equalTo(topView)
        }
        commentButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15.5)
            make.height.equalTo(25)
            make.width.equalTo(60)
            make.centerY.equalTo(topView)
        }
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(topView.snp_bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var items: [YXSClassStarChildrenModel]!{
        didSet{
            topDropView.title = "\(selectModel.text)(\(items.count - 1))"
            collectionView.items = items
        }
    }
    
    var selectModels:[YXSSelectModel] = [YXSSelectModel.init(text: "按总分排序 ", isSelect: true, paramsKey: "2"),YXSSelectModel.init(text: "按姓氏排序 ", isSelect: false, paramsKey: "1")]
    var selectModel: YXSSelectModel!{
        get {
            for model in selectModels{
                if model.isSelect{
                    return model
                }
            }
            return  selectModels[0]
        }
    }
    
    @objc func dropClick(){
        YXSHomeListSelectView.showAlert(offset: CGPoint.init(x: SCREEN_WIDTH - 8 - 143, y: 64 + kSafeTopHeight + 30), selects: selectModels) { [weak self](selectModel,selectModels) in
            guard let strongSelf = self else { return }
            strongSelf.selectModels = selectModels
            strongSelf.topDropView.title = "\(selectModel.text)(\(strongSelf.items.count - 1))"
            strongSelf.next?.yxs_routerEventWithName(eventName: kYXSClassStarTeacherPublishViewReloadDataEvent)
            
        }
    }
    
    @objc func commentClick(){
        commentButton.isSelected = !commentButton.isSelected
        for model in collectionView.items{
            model.isSelect = false
            model.isEdit =  !model.isEdit
        }
        collectionView.reloadData()
    }
    
    lazy var topView: UIView = {
        let topView = UIView()
        topView.mixedBackgroundColor = MixedColor(normal: UIColor.yxs_hexToAdecimalColor(hex: "#F2F5F9"), night: UIColor.yxs_hexToAdecimalColor(hex: "#2D2E37"))
        return topView
    }()
    
    lazy var topDropView: YXSCustomImageControl = {
        let topDropView = YXSCustomImageControl.init(imageSize: CGSize.init(width: 13.5, height: 8.5), position: YXSImagePositionType.right, padding: 11)
        topDropView.font = UIFont.boldSystemFont(ofSize: 15)
        topDropView.mixedTextColor = MixedColor(normal: UIColor.yxs_hexToAdecimalColor(hex: "#575A60"), night: UIColor.white)
        topDropView.locailImage = "yxs_punchCard_down"
        topDropView.addTarget(self, action: #selector(dropClick), for: .touchUpInside)
        return topDropView
    }()
    
    lazy var commentButton: YXSButton = {
        let button = YXSButton.init()
        button.setTitleColor(kBlueColor, for: .normal)
        button.setTitle("点评多人", for: .normal)
        button.setTitle("取消", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(commentClick), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: ClassStarTeacherPublishCollectionView = {
        let calendarViewFrame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: (SCREEN_WIDTH - 15*2 - 3*15)/4, height: 115)
        let collectionView = ClassStarTeacherPublishCollectionView(frame: calendarViewFrame, collectionViewLayout: layout)
        return collectionView
    }()
}

class ClassStarTeacherPublishCollectionView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.register(ClassStarTeacherPublishCollectionCell.self, forCellWithReuseIdentifier: "cell")
//        self.backgroundColor = UIColor.white
        self.mixedBackgroundColor = MixedColor(normal: UIColor.white, night: kNightForegroundColor)
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
    }
    var items = [YXSClassStarChildrenModel](){
        didSet{
            SLLog("reload")
            self.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ClassStarTeacherPublishCollectionCell
        cell.yxs_setCellModel(items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        if model.isEdit{
            if model.isAllChildren{
                return
            }
            model.isSelect = !model.isSelect
            collectionView.reloadItems(at: [indexPath])
            next?.yxs_routerEventWithName(eventName: kYXSClassStarTeacherPublishViewUpdateCommentButtonEvent)
        }else{
            next?.yxs_routerEventWithName(eventName: kYXSClassStarTeacherPublishViewDoCommentEvent, info: [kEventKey: model])
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ClassStarTeacherPublishCollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(leftScoreView)
        contentView.addSubview(rightScoreView)
        
        contentView.addSubview(noCommentScoreView)
        iconImageView.addSubview(maskScoreView)
        maskScoreView.addSubview(animalScoreLabel)
        
        
//        (SCREEN_WIDTH - 15*2 - 3*15)/4, height: 115
//        let itemWidth = (SCREEN_WIDTH - 15*2 - 3*15)/4
//        iconImageView.frame = CGRect(origin: CGPoint.init(x: (itemWidth - 51.0)/2.0, y: 0.0), size: CGSize.init(width: 51, height: 51))
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(contentView)
            make.width.height.equalTo(51)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp_bottom).offset(10.5)
            make.centerX.equalTo(contentView)
        }
        selectButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconImageView).offset(5)
            make.right.equalTo(iconImageView).offset(5)
            make.width.height.equalTo(27)
        }
        leftScoreView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(11)
            make.height.equalTo(14)
            make.centerX.equalTo(contentView).offset(-15)
        }
        noCommentScoreView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(11)
            make.height.equalTo(14)
            make.centerX.equalTo(contentView)
        }
        maskScoreView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        animalScoreLabel.snp.makeConstraints { (make) in
            make.center.equalTo(maskScoreView)
        }
    }
    
    var model: YXSClassStarChildrenModel!
    func yxs_setCellModel(_ model: YXSClassStarChildrenModel){
        self.model = model
        leftScoreView.isHidden = true
        rightScoreView.isHidden = true
        noCommentScoreView.isHidden = true
        selectButton.isHidden = true
        titleLabel.text =  model.isAllChildren ?  "全班" : model.childrenName ?? ""
        selectButton.isSelected = model.isSelect
        if model.isEdit && !model.isAllChildren{
            selectButton.isHidden = false
        }
        if model.isAllChildren{
            iconImageView.image = UIImage.init(named: "yxs_classstar_total_class")
        }else{
            iconImageView.sd_setImage(with: URL.init(string: model.avatar ?? ""),placeholderImage: kImageUserIconStudentDefualtImage, completed: nil)
        }
        if model.hasPraiseComment && model.hasImproveComment{
            leftScoreView.isHidden = false
            rightScoreView.isHidden = false
            
            leftScoreView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp_bottom).offset(11)
                make.height.equalTo(14)
                make.centerX.equalTo(contentView).offset(-20)
            }
            rightScoreView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp_bottom).offset(11)
                make.height.equalTo(14)
                make.centerX.equalTo(contentView).offset(20)
            }
            leftScoreView.title = "\(model.praiseScore!)"
            rightScoreView.title = "\(model.improveScore!)"
        }else if model.hasPraiseComment{
            leftScoreView.isHidden = false
            leftScoreView.title = "\(model.praiseScore!)"
            leftScoreView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp_bottom).offset(11)
                make.height.equalTo(14)
                make.centerX.equalTo(contentView)
            }
                
        }else if model.hasImproveComment{
            rightScoreView.title = "\(model.improveScore!)"
            rightScoreView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp_bottom).offset(11)
                make.height.equalTo(14)
                make.centerX.equalTo(contentView)
            }
        }else{
            noCommentScoreView.isHidden = false
        }
        if model.isShowScoreAnimal{
            setCommentAnimal()
        }
    }
    
    func setCommentAnimal(){
        maskScoreView.alpha = 1
        
        if model.scoreAnimalValue > 0{
            animalScoreLabel.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#5E88F7")
            animalScoreLabel.text = "+\(model.scoreAnimalValue)"
        }else{
            animalScoreLabel.text = "\(model.scoreAnimalValue)"
            animalScoreLabel.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#E8534C")
        }
        UIView.animate(withDuration: 2.5, animations: {
            self.maskScoreView.alpha = 0
        }) { (_) in
            self.model.isShowScoreAnimal = false
        }
    }
    
    @objc func changeSelectClick(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 25.5
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var maskScoreView: UIView = {
        let maskView = UIView()
        maskView.cornerRadius = 25.5
        maskView.alpha = 0
        maskView.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#DDE9FD", alpha: 0.5)
        return maskView
    }()
    
    lazy var animalScoreLabel: HMBordelLabel = {
        let label = HMBordelLabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()
    
    lazy var titleLabel: YXSLabel = {
        let label = YXSLabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#575A60")
        return label
    }()
    
    lazy var selectButton: YXSButton = {
        let button = YXSButton.init()
        button.setImage(UIImage.init(named: "yxs_classstar_selected"), for: .selected)
        button.setImage(UIImage.init(named: "yxs_classstar_no_select"), for: .normal)
        button.isUserInteractionEnabled = false
        //        button.addTarget(self, action: #selector(changeSelectClick), for: .touchUpInside)
        return button
    }()
    
    lazy var leftScoreView: YXSCustomImageControl = {
        let leftCommont = YXSCustomImageControl.init(imageSize: CGSize.init(width: 14, height: 14), position: YXSImagePositionType.left, padding: 3.5)
        leftCommont.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#898F9A")
        leftCommont.locailImage = "yxs_classstar_praiseScore"
        leftCommont.font = UIFont.systemFont(ofSize: 12)
        leftCommont.isUserInteractionEnabled = false
        return leftCommont
    }()
    lazy var rightScoreView: YXSCustomImageControl = {
        let leftCommont = YXSCustomImageControl.init(imageSize: CGSize.init(width: 14, height: 14), position: YXSImagePositionType.left, padding: 3.5)
        leftCommont.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#898F9A")
        leftCommont.locailImage = "yxs_classstar_improveScore"
        leftCommont.font = UIFont.systemFont(ofSize: 12)
        leftCommont.isUserInteractionEnabled = false
        return leftCommont
    }()
    
    lazy var noCommentScoreView: YXSCustomImageControl = {
        let noCommentScoreView = YXSCustomImageControl.init(imageSize: CGSize.init(width: 14, height: 14), position: YXSImagePositionType.left, padding: 3.5)
        noCommentScoreView.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#898F9A")
        noCommentScoreView.locailImage = "yxs_classstar_no_comment"
        noCommentScoreView.font = UIFont.systemFont(ofSize: 12)
        noCommentScoreView.title = "0"
        noCommentScoreView.isUserInteractionEnabled = false
        return noCommentScoreView
    }()
}

class HMBordelLabel: YXSLabel{
    override func drawText(in rect: CGRect) {
        let color = textColor
        
        let c = UIGraphicsGetCurrentContext()
        // 设置描边宽度
        c?.setLineWidth(1)
        if let c = c {
            c.setLineJoin(.round)
        }
        c?.setTextDrawingMode(.stroke)
        // 描边颜色
        textColor = UIColor.white
        super.drawText(in: rect)
        // 文本颜色
        textColor = color
        c?.setTextDrawingMode(.fill)
        super.drawText(in: rect)
    }
}
