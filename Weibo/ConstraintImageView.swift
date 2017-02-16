//
//  ConstraintImageView.swift
//  Weibo
//
//  Created by 王焕 on 16/6/3.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class ConstraintImageView: UIImageView {

    var  widthCon = NSLayoutConstraint()
    var hightCon = NSLayoutConstraint()
    var xCon = NSLayoutConstraint()
    var yCon = NSLayoutConstraint()
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    func setConstraint() {
        translatesAutoresizingMaskIntoConstraints = false
        widthCon =
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: self.superview,
                               attribute: .width,
                               multiplier: 1.0,
                               constant: 0)
        hightCon =
            NSLayoutConstraint(item: self,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.superview,
                               attribute: .height,
                               multiplier: 1.0,
                               constant: 0)
        xCon =
            NSLayoutConstraint(item: self,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.superview,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0)
        yCon =
            NSLayoutConstraint(item: self,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: self.superview,
                               attribute: .centerY,
                               multiplier: 1.0,
                               constant: 0)
        self.superview!.addConstraints([widthCon, hightCon, xCon, yCon])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
