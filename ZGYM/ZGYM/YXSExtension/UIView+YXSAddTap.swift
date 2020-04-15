//
//  UIView+addTap.swift
//  EducationShop
//
//  Created by zgjy_mac on 2019/9/29.
//  Copyright © 2019 zgjy_mac. All rights reserved.
//

import UIKit

extension UIView {
     func addTaget(target: Any, selctor: Selector?){
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: selctor)
        self.addGestureRecognizer(tap)
    }
}
