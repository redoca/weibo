//
//  UILabel+Category.swift
//  Weibo
//
//  Created by 王焕 on 16/6/16.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

extension UILabel {
    // 快速创建 UILabel
    class func creatLabel(_ color: UIColor, fontOfSize: CGFloat) -> UILabel{
        let label = UILabel()
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: fontOfSize)
        return label
    }
}
