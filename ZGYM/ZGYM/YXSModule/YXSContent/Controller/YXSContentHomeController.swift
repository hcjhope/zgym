//
//  YXSContentHomeController.swift
//  ZGYM
//
//  Created by sy_mac on 2020/4/11.
//  Copyright © 2020 hmym. All rights reserved.
//

import UIKit
import JXCategoryView
import NightNight

class YXSContentHomeController: YXSBaseViewController{
    private var listContainerView: JXCategoryListContainerView!
    ///分类model列表
    private var categoryLists: [YXSColumnModel] = [YXSColumnModel](){
        didSet{
            var titles = [String]()
            for (index,model) in categoryLists.enumerated(){
                if index == 0{
                    titles.append("推荐")
                }else{
                    titles.append(model.title ?? "")
                }
            }
            self.titles = titles
        }
    }
    ///分类标题
    private var titles: [String] = [String]()
    // MARK: -leftCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: -UI
    
    // MARK: -loadData
    func loadCategoryData(){
//        YXSEducationXMLYOperationBannersRequest.init(page: 1).requestCollection({ (list:[YXSBannerModel], pageCount) in
//            SLLog(list.toJSONString())
//        }) { (msg, code) in
//
//        }
        
        YXSEducationXMLYOperationColumnsRequest.init(page: 1).requestCollection({ (list:[YXSColumnModel], pageCount) in
            self.categoryLists = list
            self.congfigUI()
        }) { (msg, code) in
            
        }
    }
    
    // MARK: -action
    
    // MARK: -private
    
    // MARK: -public
    
    // MARK: - UI
    func congfigUI(){
        listContainerView = JXCategoryListContainerView.init(type: .collectionView, delegate: self)
        
        self.view.addSubview(categoryView)
        self.view.addSubview(listContainerView)
        categoryView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        listContainerView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.top.equalTo(categoryView.snp_bottom)
        }
        
        categoryView.contentScrollView = listContainerView.scrollView
        categoryView.delegate = self
    }
    
    
    // MARK: - getter&setter
    
    lazy var categoryView :JXCategoryTitleView = {
        //            64  8 40  15
        let view = JXCategoryTitleView()
        view.titleSelectedColor = NightNight.theme == .night ? UIColor.white : kBlueColor
        view.titleColor = NightNight.theme == .night ? kNightBCC6D4 : k575A60Color
        view.titleFont = UIFont.systemFont(ofSize: 17)
        view.titles = self.titles
        view.cellSpacing = 30
        view.isTitleColorGradientEnabled = true
        view.cellWidthIncrement = 10
        view.layer.cornerRadius = 20
        
        let lineView = JXCategoryIndicatorLineView()
        lineView.indicatorColor = UIColor.yxs_hexToAdecimalColor(hex: "#7CABFF");
        lineView.indicatorWidth = 20
        lineView.indicatorHeight = 2
        view.indicators = [lineView]
        return view
    }()
}

extension YXSContentHomeController: JXCategoryListContainerViewDelegate, JXCategoryViewDelegate{
    func number(ofListsInlistContainerView listContainerView: JXCategoryListContainerView!) -> Int {
        return categoryView.titles.count
    }
    
    func listContainerView(_ listContainerView: JXCategoryListContainerView!, initListFor index: Int) -> JXCategoryListContentViewDelegate! {
        if index == 0{
            return YXSContentListViewController.init(id: categoryLists[index].id ?? 0, showHeader: true)
        }
        return YXSContentListViewController.init(id: categoryLists[index].id ?? 0)
    }
    
    func categoryView(_ categoryView: JXCategoryBaseView!, scrollingFromLeftIndex leftIndex: Int, toRightIndex rightIndex: Int, ratio: CGFloat) {
        self.listContainerView?.scrolling(fromLeftIndex: leftIndex, toRightIndex: rightIndex, ratio: ratio, selectedIndex: categoryView.selectedIndex)
    }
    
    func categoryView(_ categoryView: JXCategoryBaseView!, didSelectedItemAt index: Int) {
        self.listContainerView?.didClickSelectedItem(at: index)
    }
}

