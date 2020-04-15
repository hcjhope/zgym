//
//  YXSClassDetialListController.swift
//  ZGYM
//
//  Created by zgjy_mac on 2019/11/21.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit
import ObjectMapper
import NightNight

class YXSClassDetialListController: YXSHomeBaseController {
    // MARK: - property
    /// 当前班级model
    private var classModel: SLClassModel
    ///当前班级学段
    private var stage: StageType = .KINDERGARTEN
    ///班级详细信息
    private var classDetialModel: YXSClassDetailModel!
    private var yxs_rightButton: YXSButton!
    ///重新刷新班级信息
    private var reloadClassDetail = true
    
    /// 导航栏 右边按钮的标题
    public var navRightBarButtonTitle: String? {
        didSet {
            if self.yxs_rightButton != nil {
                self.yxs_rightButton.setTitle(self.navRightBarButtonTitle, for: .normal)
            }
        }
    }
    
    // MARK: - init
    init(classModel: SLClassModel) {
        self.classModel = classModel
        super.init()
        tableViewIsGroup = true
        self.title = classModel.name
        isSingleHome = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - leftCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yxs_rightButton = yxs_setRightButton(title:self.navRightBarButtonTitle ?? "")
        yxs_rightButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        yxs_rightButton.setMixedTitleColor(MixedColor(normal: UIColor.yxs_hexToAdecimalColor(hex: "#575A60"), night: kNightBCC6D4), forState: .normal)
        yxs_rightButton.addTarget(self, action: #selector(yxs_rightClick), for: .touchUpInside)
        
        self.tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-kSafeBottomHeight)
        }
        yxs_tableHeaderView.layoutIfNeeded();
        let height = yxs_tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        yxs_tableHeaderView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: height )
        tableView.tableHeaderView = yxs_tableHeaderView
        tableView.estimatedRowHeight = 214
        tableView.register(YXSHomeTableSectionView.self, forHeaderFooterViewReuseIdentifier: "SLHomeTableSectionView")
        
    }
    
    // MARK: - loadData
    ///班级详情信息
    func yxs_loadClassDetailData() {
        YXSEducationGradeDetailRequest.init(gradeId: classModel.id ?? 0).request({ (model: YXSClassDetailModel) in
            self.classDetialModel = model
            if let childs = self.classDetialModel.children{
                childs.first?.isSelect = true
            }
            self.stage = StageType.init(rawValue:model.stage ?? "") ?? StageType.KINDERGARTEN
            self.reloadClassDetail = true
            self.yxs_loadListData()
            self.group.leave()
        }) { (msg, code) in
            self.view.makeToast("\(msg)")
            self.group.leave()
        }
    }
    ///瀑布流
    func yxs_loadListData(){
        group.enter()
        queue.async(group: group) {
            YXSEducationFWaterfallPageQueryRequest.init(currentPage: self.curruntPage,classIdList: [self.classModel.id ?? 0],stage: self.stage.rawValue, userType: self.yxs_user.type ?? "", childrenId: self.classModel.childrenId ?? 0).request({ (result) in
                if self.curruntPage == 1{
                    self.yxs_removeAll()
                }
                let list = Mapper<YXSHomeListModel>().mapArray(JSONObject: result["waterfallList"].object) ?? [YXSHomeListModel]()
                for model in list{
                    model.childrenId = self.classModel.childrenId
                    model.childrenRealName = self.classModel.realName
                    //置顶
                    if let isTop = model.isTop{
                        if isTop == 1 {
                            self.yxs_dataSource[0].items.append(model)
                            continue
                        }
                    }
                    //今天
                    if NSUtil.yxs_isSameDay(NSUtil.yxs_string2Date(model.createTime ?? ""), date2: Date()){
                        self.yxs_dataSource[1].items.append(model)
                        continue
                    }
                    //更早
                    self.yxs_dataSource[2].items.append(model)
                }
                self.loadMore = result["hasNext"].boolValue
                self.group.leave()
            }) { (msg, code) in
                self.group.leave()
            }
        }
        
    }
    
    override func yxs_homeLoadUpdateTopData(type: YXSHomeType, id: Int = 0, createTime: String = "", isTop: Int = 0, sucess: (() -> ())? = nil) {
        UIUtil.yxs_loadUpdateTopData(type: type, id: id, createTime: createTime, isTop: isTop, positon: .singleHome, sucess: sucess)
    }
    
    override func yxs_homeyxs_loadRecallData(model: YXSHomeListModel, sucess: (() -> ())? = nil) {
        UIUtil.yxs_loadRecallData(model, positon: .singleHome, complete: sucess)
    }
    
    override func yxs_loadData(){
        if self.curruntPage == 1 && self.reloadClassDetail{
            group.enter()
            queue.async(group: group) {
                self.yxs_loadClassDetailData()
            }
        }else{
            self.yxs_loadListData()
        }
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                self.yxs_endingRefresh()
                self.tableView.reloadData()
                self.yxs_reloadFooterView()
                
                if YXSPersonDataModel.sharePerson.personRole == .TEACHER{
                    self.yxs_tableHeaderView.teacherView.setViewModel(self.classDetialModel)
                }else{
                    self.yxs_tableHeaderView.parentView.setViewModel(self.classDetialModel,classModel: self.classModel)
                    self.yxs_tableHeaderView.childModel = self.classDetialModel.getCurruntChild(classModel: self.classModel)
                    
                }
                //更新学段
                self.yxs_tableHeaderView.setButtonUI(stage:self.stage)
            }
        }
    }
    
    // MARK: - action
    @objc func yxs_rightClick(){
        if classDetialModel.position == "HEADMASTER" {
            if self.classDetialModel == nil{
                return
            }
            let vc = YXSClassManageViewController()
            vc.className = self.classDetialModel.name ?? ""
            vc.forbidJoin = self.classDetialModel.forbidJoin == "NO" ? false:true
            vc.gradeId = self.classDetialModel.id
            vc.position = self.classDetialModel.position ?? ""
            vc.completionHandler = {[weak self](className, forbidJonin) in
                guard let weakSelf = self else {return}
                weakSelf.title = className
                weakSelf.classDetialModel.name = className
                weakSelf.classDetialModel.forbidJoin = forbidJonin == true ? "YES" : "NO"
            }
            self.navigationController?.pushViewController(vc)
            
        } else {
            let vc = YXSClassInfoViewController.init(classModel: classModel)
            self.navigationController?.pushViewController(vc)
        }
    }
    
    @objc override func yxs_publishClick(){
        YXSHomePublishView.showAlert {[weak self] (event) in
            guard let strongSelf = self else { return }
            strongSelf.yxs_dealPublishAction(event,classId: strongSelf.classModel.id ?? 0)
        }
    }
    
    // MARK: -tableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dealSelectRow(didSelectRowAt: indexPath, childModel: self.yxs_tableHeaderView.childModel)
    }
    
    
    // MARK: - getter&setter
    lazy var yxs_tableHeaderView: YXSClassDetialTableHeaderView = {
        let tableHeaderView = YXSClassDetialTableHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 350), classModel: classModel)
        return tableHeaderView
    }()
}


// MARK: -HMRouterEventProtocol
extension YXSClassDetialListController: YXSRouterEventProtocol{
    func yxs_user_routerEventWithName(eventName: String, info: [String : Any]?) {
        switch eventName {
        case kYXSHomeTableHeaderViewLookClassEvent:
            yxs_showAlert(title: "push" + kYXSHomeTableHeaderViewLookClassEvent)
        case kYXSHomeTableHeaderViewScanEvent:
            yxs_showAlert(title: "push" + kYXSHomeTableHeaderViewScanEvent)
        case kYXSClassDetialTableHeaderViewUpDateListEvent:
            reloadClassDetail = false
            yxs_refreshData()
        case kYXSClassDetialTableHeaderViewLookChildDetialEvent:
            //            showAlert(title: "push" + kYXSClassDetialTableHeaderViewLookChildDetialEvent)
            let vc = YXSClassMembersViewController()
            vc.gradeId = classModel.id ?? 0
            self.navigationController?.pushViewController(vc)
        default:
            break
        }
    }
}


// MARK: - other func
extension YXSClassDetialListController{
    func yxs_dealClassDetialListRootUI() {
        let view = UITextField()
        view.keyboardType = UIKeyboardType.numberPad
        view.leftViewMode = UITextField.ViewMode.always
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#F0F0F0")
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#FA3030")
        
        let leftView = UILabel(frame: CGRect.init(x: 0, y: 0, width: 130, height: 48))
        leftView.font = UIFont.systemFont(ofSize: 14)
        leftView.textColor = UIColor.yxs_hexToAdecimalColor(hex: "111111")
        leftView.text = "输入"
        leftView.textAlignment = NSTextAlignment.center
        view.leftView = leftView
    }
    
    func yxs_changeClassDetialListUI(_ cancelled: Bool) {
        let view = UITextField()
        view.keyboardType = UIKeyboardType.numberPad
        view.leftViewMode = UITextField.ViewMode.always
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#F0F0F0")
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#FA3030")
        
        let leftView = UILabel(frame: CGRect.init(x: 0, y: 0, width: 130, height: 48))
        leftView.font = UIFont.systemFont(ofSize: 14)
        leftView.textColor = UIColor.yxs_hexToAdecimalColor(hex: "111111")
        leftView.text = "输入"
        leftView.textAlignment = NSTextAlignment.center
        view.leftView = leftView
    }
    
    func yxs_addClassDetialListUI() {
        let view = UITextField()
        view.keyboardType = UIKeyboardType.numberPad
        view.leftViewMode = UITextField.ViewMode.always
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.yxs_hexToAdecimalColor(hex: "#F0F0F0")
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.yxs_hexToAdecimalColor(hex: "#FA3030")
        
        let leftView = UILabel(frame: CGRect.init(x: 0, y: 0, width: 130, height: 48))
        leftView.font = UIFont.systemFont(ofSize: 14)
        leftView.textColor = UIColor.yxs_hexToAdecimalColor(hex: "111111")
        leftView.text = "输入"
        leftView.textAlignment = NSTextAlignment.center
        view.leftView = leftView
    }
}