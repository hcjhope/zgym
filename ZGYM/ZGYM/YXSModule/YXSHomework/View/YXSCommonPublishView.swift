//
//  YXSCommonPublishView.swift
//  ZGYM
//
//  Created by zgjy_mac on 2019/11/25.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
import YBImageBrowser
import NightNight

private let maxcount = 9
private let textMinHeight: CGFloat = 120.0
private let kAudioViewOrginTag: Int = 101
class YXSCommonPublishView: UIView{
    // MARK: - public
    /// 输入内容时偏移更新
    public var updateContentOffSet: ((CGFloat) ->())?
    
    /// 音频最大数量
    public var audioMaxCount: Int
    
    /// 输入文本长度限制
    public var limitTextLength: Int{
        didSet{
            textView.limitCount = limitTextLength
            textView.placeholder = "请输入要发布的内容，最长支持\(limitTextLength)字"
        }
    }
    
    // MARK: - init
       init(publishModel: YXSPublishModel,isShowMedia: Bool = true,limitTextLength: Int = 1000,audioMaxCount: Int = 1) {
           self.publishModel = publishModel
           self.isShowMedia = isShowMedia
           self.limitTextLength = limitTextLength
           self.audioMaxCount = audioMaxCount
           super.init(frame: CGRect.zero)
           addSubview(listView)
           addSubview(textView)
           addSubview(textCountlabel)
           addSubview(buttonView)
           addSubview(linkView)
           mixedBackgroundColor = MixedColor(normal: UIColor.white, night: kNight20232F)
           textView.snp.makeConstraints { (make) in
               make.left.equalTo(0)
               make.right.equalTo(-15)
               make.height.equalTo(textMinHeight)
               make.top.equalTo(0)
           }
           textCountlabel.snp.makeConstraints { (make) in
               make.top.equalTo(textView.snp_bottom).offset(5)
               make.height.equalTo(20)
               make.right.equalTo(-20)
           }
           
           for index in 0..<audioMaxCount{
               let voiceView = YXSVoiceView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 36), complete: {
                   [weak self](url, duration) in
                   guard let strongSelf = self else { return }
                   strongSelf.showAudio(strongSelf.publishModel.audioModels[index], index: index)
                   }, delectHandler: {
                       [weak self] in
                       guard let strongSelf = self else { return }
                       strongSelf.removeAudio(at: index)
                   }, showDelect: true)
               voiceView.minWidth = 120
               voiceView.tapPlayer = false
               voiceView.tag = kAudioViewOrginTag + index
               voiceView.isHidden = true
               addSubview(voiceView)
           }
           
           textView.text = publishModel.publishText
           
           initListViewUI()
           
           updateUI()
       }
    
    // MARK: - private property
    private var publishModel: YXSPublishModel
    
    /// 用来预览展示选择(q全是本地的)
    private var assets: [TZAssetModel] {
        get{
            var assets = [TZAssetModel]()
            for media in publishModel.medias{
                if let tzModel: TZAssetModel = TZAssetModel.init(asset: media.asset, type: TZAssetModelMediaTypePhoto), !media.isService{
                    assets.append(tzModel)
                }
            }
            return assets
        }
    }
    
    /// 用来预览展示的服务器资源
    private var serviceMedias: [String] {
        get{
            var serviceMedias = [String]()
            for media in publishModel.medias{
                if media.isService{
                    serviceMedias.append(media.serviceUrl ?? "")
                }
            }
            return serviceMedias
        }
    }
    /// 是添加图片点击
    private var isAdd: Bool = false
    
    /// 是否已选择发布视频
    private var isVedio: Bool{
        var isVedio = false
        for media in publishModel.medias{
            if media.type == PHAssetMediaType.video{
                isVedio = true
                break
            }
        }
        return isVedio
    }
    
    /// 是否有媒体资源展示
    private var isShowMedia: Bool
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化listView
    private func initListViewUI(){
        //初始化媒体库
        if publishModel.medias == nil{
            publishModel.medias = [SLPublishMediaModel]()
        }
        
        for media in publishModel.medias{
            listView.addItem(getItem(media))
        }
    }
    
    // MARK: - UI
    private func updateUI(){
        for index in 0..<audioMaxCount{
            let view = self.viewWithTag(kAudioViewOrginTag + index)
            view?.isHidden = true
        }
        self.publishModel.publishSource.removeAll()
        
        let textOrginHeight = textView.height
        let size = textView.sizeThatFits(CGSize.init(width: SCREEN_WIDTH - 30, height: 3000))
        let textHeight = size.height + 20 > textMinHeight ? size.height + 20 : textMinHeight
        textView.snp.updateConstraints({ (make) in
            make.height.equalTo(textHeight)
        })
        updateContentOffSet?(textHeight - textOrginHeight)
        if isShowMedia{
            var frame = listView.frame
            frame.origin.y = 50 + textHeight
            
            if publishModel.audioModels.count != 0{
                for index in 0..<publishModel.audioModels.count{
                    let voiceView = viewWithTag(index + kAudioViewOrginTag) as? YXSVoiceView
                    if let voiceView = voiceView{
                        voiceView.isHidden = false
                        voiceView.frame = CGRect.init(x: 15, y: frame.origin.y, width: SCREEN_WIDTH - 30, height: 35)
                        frame.origin.y += 65
                        
                        let vModel = YXSVoiceViewModel()
                        vModel.voiceDuration = publishModel.audioModels[index].time ?? 0
                        voiceView.model = vModel
                    }
                }
                
            }else{
                frame.origin.y = textHeight + 50
            }
            listView.frame = frame
            
            if publishModel.publishLink == nil{
                linkView.isHidden = true
                
                buttonView.snp.remakeConstraints { (make) in
                    make.top.equalTo(listView.itemListH + frame.origin.y + 20)
                    make.left.right.equalTo(0)
                    make.bottom.equalTo(-20)
                    make.height.equalTo(29)
                }
                
            }else{
                linkView.isHidden = false
                linkView.btnLink.setTitle(publishModel.publishLink, for: .normal)
                linkView.snp.remakeConstraints { (make) in
                    make.top.equalTo(listView.itemListH + frame.origin.y + 20)
                    make.left.equalTo(15)
                    make.right.equalTo(-15)
                    make.height.equalTo(44)
                }
                buttonView.snp.remakeConstraints { (make) in
                    make.top.equalTo(linkView.snp_bottom).offset(15.5)
                    make.left.right.equalTo(0)
                    make.bottom.equalTo(-20)
                    make.height.equalTo(29)
                }
            }
    
            if publishModel.audioModels.count != 0{
                if publishModel.audioModels.count == audioMaxCount{
                    self.publishModel.publishSource.append(.audioMax)
                }else{
                    self.publishModel.publishSource.append(.audio)
                }
            }
            
            if isVedio {
                self.publishModel.publishSource.append(.video)
            }else if publishModel.medias.count != 0 {
                if assets.count == maxcount{
                    self.publishModel.publishSource.append(.imageMax)
                }else{
                   self.publishModel.publishSource.append(.image)
                }
            }
            if publishModel.audioModels.count == 0 && assets.count == 0{
                publishModel.publishSource.append(.none)
            }
            
            buttonView.changeButtonStates(publishModel.publishSource)
        }else{
            textCountlabel.snp.remakeConstraints { (make) in
                make.top.equalTo(textView.snp_bottom).offset(5)
                make.height.equalTo(20)
                make.right.equalTo(-20)
                make.bottom.equalTo(-20)
            }
            buttonView.isHidden = true
            linkView.isHidden = true
            listView.isHidden = true
        }
        
    }
    
    // MARK: - tool
    
    /// 移除音频
    /// - Parameter index: 音频位置
    private func removeAudio(at index: Int){
        publishModel.audioModels.remove(at: index)
        updateUI()
    }
    
    private func changeModel(){
        publishModel.medias.removeAll()
        for item in listView.itemArray(){
            if !item.isAdd{
                publishModel.medias.append(item.model!)
            }
        }
    }
    
    // MARK: - action
    
    /// 内容下的按钮事件
    /// - Parameter event: 事件类型
    private func dealButtonViewEvent(_ event: PublishViewButtonEvent)
    {
        self.endEditing(true)
        switch event {
        case .audio:
            showAudio()
        case .image:
            isAdd = true
            showSelectMedia(true)
        case .link:
            YXSHomeworkInputLinkAlert.showAlert(publishModel.publishLink) { [weak self](link) in
                guard let strongSelf = self else { return }
                strongSelf.publishModel.publishLink = link
                strongSelf.updateUI()
            }
        case .vedio:
            let vc = YXSRecordVideoController.init(complete: { [weak self](asset) in
                guard let strongSelf = self else { return }
                strongSelf.addSingleMedia(asset: asset)
            })
            vc.modalPresentationStyle = .fullScreen
            UIUtil.RootController().present(vc, animated: true, completion: nil)
        }
    }
    
    /// show音频视图
    /// - Parameters:
    ///   - model: 需要展示的model  nil为去录制音频
    ///   - index: 当前展示的音频是第几个
    private func showAudio(_ model:SLAudioModel? = nil,index: Int? = nil){
        let audioView = YXSRecordAudioView.showRecord(audio: model) { [weak self](audio) in
            guard let strongSelf = self else { return }
            if let index = index{
                strongSelf.publishModel.audioModels[index] = audio
            }else{
                strongSelf.publishModel.audioModels.append(audio)
            }
            
            strongSelf.updateUI()
        }
        audioView.sourceDirectory = publishModel.sourceDirectory
    }
    
    /// 展示选择媒体资源
    /// - Parameter isAdd: 是否是新增
    private func showSelectMedia(_ isAdd: Bool){
        let count = maxcount - assets.count - serviceMedias.count
        
        if isAdd{
            YXSSelectMediaHelper.shareHelper.pushImagePickerController(mediaStyle: .onlyImage,maxCount: count)
        }else{
            YXSSelectMediaHelper.shareHelper.pushImagePickerController(assets,mediaStyle: .onlyImage,maxCount: maxcount - serviceMedias.count)
        }
        
        YXSSelectMediaHelper.shareHelper.delegate = self
    }
    
    
    /// 添加单个展示item
    /// - Parameter asset: 媒体资源
    private func addSingleMedia(asset: YXSMediaModel){
        listView.addItem(getItem(asset))
        changeModel()
        updateUI()
    }

    
    // MARK: - getter&setter
    lazy var textView : YXSPlaceholderTextView = {
        let textView = YXSPlaceholderTextView()
        textView.limitCount = limitTextLength
        textView.font = kTextMainBodyFont
        textView.placeholderMixColor = MixedColor(normal: kNight898F9A, night: kNight898F9A)
        let textColor = NightNight.theme == .night ? UIColor.white : kTextMainBodyColor
        textView.mixedBackgroundColor = MixedColor(normal: UIColor.white, night: kNight20232F)
        textView.placeholder = "请输入要发布的内容，最长支持\(limitTextLength)字"
        textView.contentInset = UIEdgeInsets.init(top: 20, left: 15, bottom: 0, right: 0)
        textView.textDidChangeBlock = {
            [weak self](text: String) in
            guard let strongSelf = self else { return }
            strongSelf.textCountlabel.text = "\(text.count)/\(strongSelf.limitTextLength)"
            strongSelf.publishModel.publishText = text
            strongSelf.updateUI()
        }
        
        let paragraphStye = NSMutableParagraphStyle()
        //调整行间距
        paragraphStye.lineSpacing = 7
        paragraphStye.lineBreakMode = NSLineBreakMode.byWordWrapping
        textView.typingAttributes = [NSAttributedString.Key.paragraphStyle:paragraphStye,NSAttributedString.Key.font: kTextMainBodyFont, NSAttributedString.Key.foregroundColor: textColor]
        return textView
    }()
    
    private lazy var textCountlabel: YXSLabel = {
        let label = YXSLabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.mixedTextColor = MixedColor(normal: UIColor.yxs_hexToAdecimalColor(hex: "#C4CDDA"), night: kNightBCC6D4)
        label.text = "0/\(limitTextLength)"
        return label
    }()
    
    private lazy var listView:SLFriendDragListView = {
        let listView = SLFriendDragListView.init(frame: CGRect.init(x: 0, y: 170, width: SCREEN_WIDTH, height: 0))
        listView.scaleItemInSort = 1.3
        listView.isSort = false
        listView.maxItem = maxcount
        listView.isFitItemListH = true
        listView.clickItemBlock = {[weak self](item) in
            guard let strongSelf = self else { return }
            strongSelf.isAdd = false
            if !strongSelf.isVedio{
                var urls = [URL]()
                var assets = [PHAsset]()
                if item.model?.serviceUrl == nil{
                    for model in strongSelf.assets{
                        assets.append(model.asset)
                    }
                }else{
                    for url in strongSelf.serviceMedias{
                        urls.append(URL.init(string: url)!)
                    }
                }
                YXSShowBrowserHelper.showImage(urls: urls, assets: assets, curruntIndex: item.tag)
                
            }else{
                //本地预览
                if !(item.model?.isService ?? false){
                    YXSShowBrowserHelper.showVedio(assets: item.model?.asset)
                }else{//网络预览
                    UIUtil.pushOpenVideo(url: item.model?.serviceUrl ?? "")
                }
            }
        }
        return listView
    }()
    
    private lazy var buttonView: SLPublishViewButtonView = {
        let buttonView = SLPublishViewButtonView.init(isFriend: publishModel.isFriendCiclePublish)
        buttonView.buttonClickBlock = {[weak self](event) in
            guard let strongSelf = self else { return }
            strongSelf.dealButtonViewEvent(event)
            
        }
        return buttonView
    }()
    
    
    lazy var linkView: SLPublishLinkView = {
        let linkView = SLPublishLinkView.init {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.publishModel.publishLink = nil
            strongSelf.updateUI()
        }
        linkView.isHidden = true
        return linkView
    }()
}

// MARK: - YXSSelectMediaHelperDelegate
extension YXSCommonPublishView: YXSSelectMediaHelperDelegate{
    
    func didSelectMedia(asset: YXSMediaModel) {
        addSingleMedia(asset: asset)
    }
    
    func didSelectSourceAssets(assets: [YXSMediaModel]) {
        if !isAdd{
            if serviceMedias.count != 0{
                for asset in self.assets{
                    for item in listView.itemArray(){
                        if item.model?.asset == asset{
                            listView.delete(item)
                        }
                    }
                }
            }else{
                listView.removeAll()
            }
        }
        
        for media in assets{
            listView.addItem(getItem(media))
        }
        changeModel()
        updateUI()
    }
}

// MARK: - SLFriendDragItem
extension YXSCommonPublishView{
    /// 创建 SLFriendDragItem
    /// - Parameter model: 本地资源Model
    /// - Parameter isAdd: 是否是添加按钮
    func getItem(_ model: YXSMediaModel? = nil, isAdd: Bool = false) -> SLFriendDragItem{
        let publishMedia = SLPublishMediaModel()
        publishMedia.asset = model?.asset
        return self.getItem(publishMedia, isAdd: isAdd)
    }
    
    /// 创建 SLFriendDragItem
    /// - Parameters:
    ///   - publishModel: 服务资源Model
    ///   - isAdd: 是否是添加按钮
    func getItem(_ publishModel: SLPublishMediaModel? = nil, isAdd: Bool = false) -> SLFriendDragItem{
        let item = SLFriendDragItem.init(frame: CGRect.zero)
        item.contentMode = .scaleAspectFill
        item.clipsToBounds = true
        if isAdd{
            item.isAdd = isAdd
        }else{
            item.model = publishModel
        }
        item.itemRemoveBlock =  {
            [weak self](model: SLPublishMediaModel) in
            guard let strongSelf = self else { return }
            strongSelf.publishModel.medias.remove(at:  strongSelf.publishModel.medias.firstIndex(of: model) ?? 0)
            
            for item in strongSelf.listView.itemArray(){
                if item.model == model{
                    strongSelf.listView.delete(item)
                    break
                }
            }
            strongSelf.updateUI()
        }
        return item
    }
}