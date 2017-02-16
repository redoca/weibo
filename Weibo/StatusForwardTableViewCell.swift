//
//  StatusForwardTableViewCell.swift
//  Weibo
//  转发微博 cell
//  Created by 王焕 on 16/6/21.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class StatusForwardTableViewCell: StatusTableViewCell {

    // 重写不会覆盖父类操作, 且父类是 didSet， 那么子类也只能重写 didSet
    override var status: Status? {
        didSet {
            let name = status?.retweeted_status?.user?.name ?? ""
            let text = status?.retweeted_status?.text ?? ""
            forwardLabel.attributedText = Emoticon.emoticonAttributedStr(str: name + ": " + text, font: forwardLabel.font)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        // 1.添加子控件
        contentView.insertSubview(forwardBtn, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview: forwardBtn)
        
        // 2.布局了控件
        forwardBtn.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -10, y: 10))
        forwardBtn.xmg_AlignVertical(type: XMG_AlignType.topRight, referView: footerView, size: nil)
        forwardLabel.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: forwardBtn, size: nil, offset: CGPoint(x: 10, y: 10))
        
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: forwardLabel, size: CGSize.zero, offset: CGPoint(x: 0, y: 10))
        picWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.width)
        picHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.height)
        picTopCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.top)
    }
    
    // MARK: - 懒加载
    
    /// 转发正文
    private lazy var forwardLabel: UILabel = {
        let label = UILabel.creatLabel(UIColor.darkGray, fontOfSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 20 //限制最大宽度
        return label
    }()
    
    private lazy var forwardBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return btn
    }()
}
