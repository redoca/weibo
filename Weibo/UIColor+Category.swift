//
//  UIColor+Category.swift
//  Weibo
//
//  Created by 王焕 on 16/8/26.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 随机颜色
    ///
    /// - returns: 随机颜色
    class func randomColor() -> UIColor {
        return UIColor(red: randomNumber(), green: randomNumber(), blue: randomNumber(), alpha: 1.0)
    }
    
    class func randomNumber() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / CGFloat(255)
    }
}
