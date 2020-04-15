//
//  SLMoveToViewController.swift
//  ZGYM
//
//  Created by Liu Jie on 2020/4/10.
//  Copyright © 2020 hmym. All rights reserved.
//

import UIKit
import NightNight
import ObjectMapper

class SLMoveToViewController: YXSBaseTableViewController {

    var oldParentFolderId: Int = -1
    var parentFolderId: Int = -1
    var folderList: [SLFolderModel] = [SLFolderModel]()
    
    var selectedFolderList: [Int] = [Int]()
    var selectedFileIdList: [Int] = [Int]()
    
//    var completionHandler: ((_ folderIdList: [Int], _ fileIdList: [Int], _ oldParentFolderId: Int, _ parentFolderId: Int)-> Void)?
    var completionHandler: ((_ oldParentFolderId: Int, _ parentFolderId: Int)-> Void)?
    
    init(folderIdList: [Int] = [Int](), fileIdList: [Int] = [Int](), oldParentFolderId: Int = -1, parentFolderId: Int = -1, completionHandler:((_ oldParentFolderId: Int, _ parentFolderId: Int)->())?) {
        super.init()

        self.oldParentFolderId = oldParentFolderId
        self.parentFolderId = parentFolderId
        self.selectedFolderList = folderIdList
        self.selectedFileIdList = fileIdList
        
        self.completionHandler = completionHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "移动文件"
        
        view.mixedBackgroundColor = MixedColor(normal: kNightFFFFFF, night: kNightBackgroundColor)
        tableView.mixedBackgroundColor = MixedColor(normal: kTableViewBackgroundColor, night: kNightBackgroundColor)
        
        tableView.register(SLFileGroupCell.classForCoder(), forCellReuseIdentifier: "SLFileGroupCell")
        tableView.register(SLFileCell.classForCoder(), forCellReuseIdentifier: "SLFileCell")
        
        tableView.snp.remakeConstraints({ (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        })
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints({ (make) in
            make.top.equalTo(tableView.snp_bottom)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(60)
        })
        
        loadData()
        
    }
    
    // MARK: - Request
    @objc func loadData() {
        YXSSatchelFolderPageQueryRequest(currentPage: curruntPage, parentFolderId: parentFolderId).request({ [weak self](json) in
            guard let weakSelf = self else {return}
            let hasNext = json["hasNext"]
            
            weakSelf.folderList = Mapper<SLFolderModel>().mapArray(JSONString: json["satchelFolderList"].rawString()!) ?? [SLFolderModel]()
            weakSelf.tableView.reloadData()
            
        }) { (msg, code) in
            MBProgressHUD.yxs_showMessage(message: msg)
        }
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = folderList[indexPath.row]
        let cell: SLFileGroupCell = tableView.dequeueReusableCell(withIdentifier: "SLFileGroupCell") as! SLFileGroupCell
        cell.model = item
        cell.lbTitle.text = item.folderName//"作业"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.mixedBackgroundColor = MixedColor(normal: kNightFFFFFF, night: kNightFFFFFF)
        let lb = YXSLabel()
        lb.text = "将文件移动到："
        lb.mixedTextColor = MixedColor(normal: kNight898F9A, night: kNight898F9A)
        lb.textAlignment = .left
        lb.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(lb)
        lb.snp.makeConstraints({ (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-10)
        })
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = folderList[indexPath.row]
        
        let vc = SLMoveToViewController(folderIdList: selectedFolderList, fileIdList: selectedFileIdList, oldParentFolderId: oldParentFolderId, parentFolderId: item.id ?? 0, completionHandler: completionHandler)
        
//        let vc = SLMoveToViewController(folderIdList: selectedFolderList, fileIdList: selectedFileIdList, oldParentFolderId: oldParentFolderId, parentFolderId: item.id ?? 0) { [weak self](oldParentFolderId, parentFolderId) in
//            guard let weakSelf = self else {return}
//            /// code do something
//
//            weakSelf.completionHandler?(oldParentFolderId, parentFolderId)
//        }

        navigationController?.pushViewController(vc)
    }
    
    // MARK: - Action
    @objc func createFolderBtnClick(sender: YXSButton) {
        let view = YXSInputAlertView2.showIn(target: self.view) { [weak self](result, btn) in
            guard let weakSelf = self else {return}
            YXSSatchelCreateFolderRequest(folderName: result, parentFolderId: weakSelf.parentFolderId).request({ [weak self](json) in
                guard let weakSelf = self else {return}
                if btn.titleLabel?.text == "创建" {
                    weakSelf.loadData()
                }
                
            }) { (msg, code) in
                MBProgressHUD.yxs_showMessage(message: msg)
            }
        }
        view.lbTitle.text = "创建文件夹"
        view.tfInput.placeholder = "请输入文件夹名称"
        view.btnDone.setTitle("创建", for: .normal)
        view.btnCancel.setTitle("取消", for: .normal)
    }
    
    @objc func moveBtnClick(sender: YXSButton) {
        
        YXSSatchelBatchMoveRequest(folderIdList: selectedFolderList, fileIdList: selectedFileIdList, oldParentFolderId: oldParentFolderId, parentFolderId: parentFolderId).request({ [weak self](json) in
            guard let weakSelf = self else {return}
            if json.stringValue.count > 0 {
                MBProgressHUD.yxs_showMessage(message: json.stringValue)
            }
            weakSelf.completionHandler?(weakSelf.oldParentFolderId, weakSelf.parentFolderId)
            weakSelf.dismiss(animated: true, completion: nil)
            
        }) { (msg, code) in
            MBProgressHUD.yxs_showMessage(message: msg)
        }
    }
    
    
    
    // MARK: - LazyLoad
    lazy var bottomView: SLMoveToBottomView = {
        let view = SLMoveToBottomView()
        view.btnFirst.addTarget(self, action: #selector(createFolderBtnClick(sender:)), for: .touchUpInside)
        view.btnSecond.addTarget(self, action: #selector(moveBtnClick(sender:)), for: .touchUpInside)
        return view
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class SLMoveToBottomView: UIView {
    init() {
        super.init(frame: CGRect.zero)
        mixedBackgroundColor = MixedColor(normal: kNightFFFFFF, night: kNightFFFFFF)
        addSubview(btnFirst)
        addSubview(btnSecond)
        
        btnFirst.snp.makeConstraints({ (make) in
            make.centerY.equalTo(snp_centerY)
            make.height.equalTo(40)
            make.left.equalTo(15)
            make.right.equalTo(snp_centerX).offset(-7.5)
        })

        btnSecond.snp.makeConstraints({ (make) in
            make.centerY.equalTo(snp_centerY)
            make.height.equalTo(40)
            make.left.equalTo(snp_centerX).offset(7.5)
            make.right.equalTo(-15)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LazyLoad
    lazy var btnFirst: YXSButton = {
        let btn = YXSButton()
        btn.setTitle("创建文件夹", for: .normal)
        btn.setTitleColor(kNight5E88F7, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.backgroundColor = kNightFFFFFF
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        btn.borderWidth = 0.5
        btn.borderColor = kNight5E88F7
        return btn
    }()
    
    lazy var btnSecond: YXSButton = {
        let btn = YXSButton()
        btn.setTitle("移动", for: .normal)
        btn.setTitleColor(kNightFFFFFF, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.backgroundColor = kNight5E88F7
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
}