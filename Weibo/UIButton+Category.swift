//
//  UIButton+Category.swift
//  Weibo
//
//  Created by 王焕 on 16/6/16.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

extension UIButton {
    
    // home cell footer btn
    class func createButton(_ imageName: String, title: String) -> UIButton{
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), for: UIControlState())
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setBackgroundImage(UIImage(named:"timeline_card_bottom_background"),
                               for: UIControlState())
        btn.setTitleColor(UIColor.darkGray, for: UIControlState())
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        return btn
    }
}
