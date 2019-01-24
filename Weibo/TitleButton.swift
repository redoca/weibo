//
//  TitleButton.swift
//  Weibo
//
//  Created by 王焕 on 16/5/10.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class TitleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
            setTitleColor(UIColor.darkGray, for: UIControlState())
            setImage(UIImage(named: "navigationbar_arrow_down"), for: UIControlState())
            setImage(UIImage(named: "navigationbar_arrow_up"), for: UIControlState.selected)
            sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init (Coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Swift 中是可以真接更改 frame.origin.x
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.size.width
    }
}
