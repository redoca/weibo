//
//  UIBarButtonItem+Category.swift
//  Weibo
//
//  Created by 王焕 on 16/5/4.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func creatBarButtonItem(_ imageName: String, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName),
                     for: UIControlState())
        btn.setImage(UIImage(named: imageName + "_highlighted"),
                     for: UIControlState.highlighted)
        btn.sizeToFit()
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: btn)
    }
    convenience init(imageName:String, target: AnyObject?, action: String?) {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), for: UIControlState.normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), for: UIControlState.highlighted)
        if action != nil
        {
            // 如果是自己封装一个按钮, 最好传入字符串, 然后再将字符串包装为Selector
            btn.addTarget(target, action: Selector(action!), for: UIControlEvents.touchUpInside)
        }
        btn.sizeToFit()
        self.init(customView: btn)
    }

}
