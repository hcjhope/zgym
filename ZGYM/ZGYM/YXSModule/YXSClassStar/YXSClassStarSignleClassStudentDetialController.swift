//
//  YXSClassStarSignleClassStudentDetialController.swift
//  ZGYM
//
//  Created by zgjy_mac on 2019/12/9.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit


/// 班级之星老师单个详情
class YXSClassStarSignleClassStudentDetialController: YXSClassStarSignleClassBaseController {
    
    /// 孩子信息
    var childrenModel: YXSClassStarChildrenModel
    var dataSource: [YXSClassStarHistoryModel] = [YXSClassStarHistoryModel]()
    /// 当前班级id
    var classId: Int = 0
    /// 刷新孩子信息
    var reloadChildrenInfo = true
    
    /// 弹窗点评model
    var alertModel:ClassStarCommentTotalModel!
    
    init(childrenModel: YXSClassStarChildrenModel,classId: Int) {
        self.childrenModel = childrenModel
        super.init()
        tableViewIsGroup = true
        showBegainRefresh = false
        hasRefreshHeader = false
        
        self.classId = classId
    }
    
    
    /// 初始化
    /// - Parameters:
    ///   - childreId: 孩子id
    ///   - classId: 班级id
    convenience init(childreId: Int,classId: Int,stage: StageType) {
        let childrenModel = YXSClassStarChildrenModel.init(JSON: ["":""])!
        childrenModel.childrenId = childreId
        childrenModel.dateType = .W
        childrenModel.stageType = stage
        self.init(childrenModel: childrenModel,classId: classId)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -leftCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customNav.title = childrenModel.childrenName
        
        tableView.tableHeaderView = tableHeaderView
        tableView.rowHeight = 69
        tableView.register(YXSClassStarTeacherSingleCell.self, forCellReuseIdentifier: "YXSClassStarTeacherSingleCell")
        tableView.register(YXSClassStarTeacherSingleHeaderView.self, forHeaderFooterViewReuseIdentifier: "YXSClassStarTeacherSingleHeaderView")
        tableView.tableFooterView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 20))

        loadData()
    }

    
    // MARK: -loadData
    
    override func yxs_loadNextPage() {
        loadData()
    }
    
    override func uploadData() {
        currentPage = 1
        childrenModel.dateType = DateType.init(rawValue: selectModel.paramsKey) ?? DateType.W
        reloadChildrenInfo = true
        loadData()
    }
    
    let queue = DispatchQueue.global()
    let group = DispatchGroup()
    override func loadData() {
        if reloadChildrenInfo{
            group.enter()
            queue.async {
                DispatchQueue.main.async {
                    self.loadClassChildrensData()
                }
                
            }
        }
        
        group.enter()
        if currentPage == 1{
        }
        queue.async {
            DispatchQueue.main.async {
                self.loadListData()
            }
        }
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                self.yxs_endingRefresh()
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    func loadClassChildrensData(){
        YXSEducationClassStarChildrenScoreDetailRequest.init(classId: classId,childrenId: childrenModel.childrenId ?? 0,dateType: childrenModel.dateType).request({ (childModel: YXSClassStarChildrenModel) in
            childModel.dateType = self.childrenModel.dateType
            childModel.stageType = self.childrenModel.stageType
            childModel.childrenId = self.childrenModel.childrenId
            self.childrenModel = childModel
            self.reloadChildrenInfo = false
            DispatchQueue.main.async {
                self.customNav.title = childModel.childrenName
                self.tableHeaderView.setHeaderModel(self.childrenModel)
            }
            self.group.leave()
        }) { (msg, code) in
            MBProgressHUD.yxs_showMessage(message: msg)
            self.group.leave()
        }
    }
    
    func loadListData(){
        YXSEducationClassStarTeacherEvaluationHistoryListPageRequest.init(childrenId:childrenModel.childrenId ?? 0,classId: classId, currentPage: currentPage,dateType: childrenModel.dateType).requestCollection({ (list:[YXSClassStarHistoryModel]) in
            if self.currentPage == 1{
                self.dataSource.removeAll()
            }
            self.dataSource += list
            self.group.leave()
        }) { (msg, code) in
            self.group.leave()
        }
    }

    
    /// 点评列表
    func loadEvaluationListData(){
        YXSEducationFEvaluationListListRequest.init(classId: classId, stage: childrenModel.stageType).requestCollection({ (list: [YXSClassStarCommentItemModel]) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if self.childrenModel.stageType == .KINDERGARTEN{
                var source = list
                self.alertModel = ClassStarCommentTotalModel.init(titles: ["表扬"], dataSource: [list],classId:self.classId,stage: self.childrenModel.stageType)
            }else{
                var pariseLists = [YXSClassStarCommentItemModel]()
                var impLists = [YXSClassStarCommentItemModel]()
                for model in list{
                    if model.score ?? 0 >= 0{
                        pariseLists.append(model)
                    }else{
                        impLists.append(model)
                    }
                }
                self.alertModel = ClassStarCommentTotalModel.init(titles: ["表扬", "待改进"], dataSource: [pariseLists,impLists],classId:self.classId,stage: self.childrenModel.stageType)
                
                self.dealCommentEvent()
            }
        }) { (msg, code) in
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.yxs_showMessage(message: msg)
        }
    }
    
    
    // MARK: - private
    //处理点评事件
    func dealCommentEvent(){
        if alertModel == nil{
            loadEvaluationListData()
            return
        }
        showCommentStudentView(childrenModel)
    }
    
    /// 发布点评弹窗
    /// - Parameter model: 被点评的孩子
    func showCommentStudentView(_ model: YXSClassStarChildrenModel){
        var childrenIds: [Int] = [Int]()
        let selectComments: [YXSClassStarChildrenModel] = [model]
        //点击评论
        for model in selectComments{
            childrenIds.append(model.childrenId ?? 0)
        }
        alertModel.childrenIds = childrenIds
        alertModel.alertTitle = "点评\(model.childrenName ?? "")"
        YXSClassStarCommentWindowView.showClassStarComment(model: self.alertModel) {
            [weak self](item) in
            guard let strongSelf = self else { return }
            strongSelf.reloadChildrenInfo = true
            strongSelf.loadData()
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kUpdateClassStarScoreNotification), object: nil)
        }
    }
    
    // MARK: - public
    ///删除点评项
    public func delectItems(items: [YXSClassStarCommentItemModel], defultIndex: Int){
        var lists = alertModel.dataSource[defultIndex]
        for model in items{
            for source in lists{
                if model.id == source.id{
                    lists.remove(at: lists.firstIndex(of: source) ?? 0)
                    break
                }
            }
            
        }
        alertModel.dataSource[defultIndex] = lists
    }
    
    /// 更新点评项
    /// - Parameters:
    ///   - item: 点评item
    ///   - defultIndex: 哪个section
    ///   - isUpdate: 是否是更新(false 为新增item)
    public func updateItems(item: YXSClassStarCommentItemModel, defultIndex: Int, isUpdate: Bool){
        var lists = [YXSClassStarCommentItemModel]()
        if isUpdate{
            for model in alertModel.dataSource[defultIndex]{
                if model.id == item.id{
                    lists.append(item)
                }else{
                    lists.append(model)
                }
            }
        }else{
            for (index,model) in alertModel.dataSource[defultIndex].enumerated(){
                if index == 2{
                    lists.append(item)
                }
                lists.append(model)
            }
        }
        alertModel.dataSource[defultIndex] = lists
    }
    
    // MARK: -tableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXSClassStarTeacherSingleCell") as! YXSClassStarTeacherSingleCell
        cell.yxs_setCellModel(dataSource[indexPath.row])
        cell.isLastRow = indexPath.row == dataSource.count - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: YXSClassStarTeacherSingleHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YXSClassStarTeacherSingleHeaderView") as! YXSClassStarTeacherSingleHeaderView
        header.quickCommentControl.isHidden = false
        return header
        
    }
    
    // MARK: - getter&setter
    lazy var tableHeaderView: YXSClassStartTeacherDetailStudentHeaderView = {
        let tableHeaderView = YXSClassStartTeacherDetailStudentHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: (childrenModel.stageType == StageType.KINDERGARTEN ? 370.5 : 380.5)*SCREEN_SCALE + kSafeTopHeight),stage: childrenModel.stageType)
        return tableHeaderView
    }()
}


// MARK: -HMRouterEventProtocol
extension YXSClassStarSignleClassStudentDetialController{
    override func yxs_user_routerEventWithName(eventName: String, info: [String : Any]?) {
        super.yxs_user_routerEventWithName(eventName: eventName, info: info)
        switch eventName {
        case kYXSClassStarTeacherSingleHeaderViewQuickCommentEvent:
            dealCommentEvent()
        default:
            break
        }
    }
}


