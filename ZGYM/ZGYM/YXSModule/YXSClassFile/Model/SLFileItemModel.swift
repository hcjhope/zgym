//
//  SLFileItemModel.swift
//  ZGYM
//
//  Created by Liu Jie on 2020/3/25.
//  Copyright © 2020 hmym. All rights reserved.
//

import UIKit

public enum SLFileExtension: String  {
    case pptx
    case docx
    case xlsx
    case pdf
    case jpg
    case m4a
    case mp3
    case wav
    case ogg
    case m4r
    case acc
    case mp4
    case MP4
    case mov
}


class SLFileItemModel: NSObject {
    
    var fileName: String?
    var data: Data?
    var exteonsion: SLFileExtension?
    /// MB
    var fileSize: CGFloat?
    var date: String?
    var fullPath: String?
}
