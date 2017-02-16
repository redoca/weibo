//
//  StatusNormalTableViewCell.swift
//  Weibo
//  原创微博 cell
//  Created by 王焕 on 16/6/22.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class StatusNormalTableViewCell: StatusTableViewCell {
    override func setupUI() {
        super.setupUI()
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: contentLabel, size: CGSize.zero, offset: CGPoint(x: 0, y: 10))
        picWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.width)
        picHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.height)
    }
}
