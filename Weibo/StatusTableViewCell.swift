//
//  StatusTableViewCell.swift
//  Weibo
//
//  Created by 王焕 on 16/6/16.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SDWebImage
import KILabel

let kPicViewCellReuseIdentifier = "kPicViewCellReuseIdentifier"

/// 保存 cell 重用标示
enum StatusTableViewCellIdentifier: String {
    case NormalCell = "NormalCell"
    case ForwardCell = "ForwardCell"
    
    // 如果在枚举中利用 static 修饰一个方法，相当于类中的 class 修饰方法
    // 如果调用枚举值的 rawValue, 那么意味着拿到枚举对应的原始值
    static func cellID(_ status: Status) -> String {
        return status.retweeted_status != nil ? ForwardCell.rawValue : NormalCell.rawValue
    }
}

class StatusTableViewCell: UITableViewCell {

    /// 保存配图的高宽约束
    var picWidthCons: NSLayoutConstraint?
    var picHeightCons: NSLayoutConstraint?
    var picTopCons: NSLayoutConstraint?

    var status: Status? {
        didSet {
            //设置顶视图数据
            topView.status = status
            // 设置正文
            contentLabel.attributedText = Emoticon.emoticonAttributedStr(str: (status?.text)!, font: contentLabel.font)
            
            // 设置配图的尺寸
            // 1.1根据模型计算配图的尺寸
            pictureView.status = status?.retweeted_status != nil ? status?.retweeted_status : status
            let size =  pictureView.calculateImageSize()
            // 1.2设置配图的尺寸
            picWidthCons?.constant = size.width
            picHeightCons?.constant = size.height
            picTopCons?.constant = size.height == 0 ? 0 : 10
        }
    }
    
    // 自定义一个类，需要重写的init方法是 designated
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 初始化UI
        setupUI()
    }
    
    func setupUI() {
        
        // 1.添加子控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(footerView)
        contentView.addSubview(pictureView)
        
        // 2.布局子控件
        let width = UIScreen.main.bounds.width
        
        topView.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: contentView, size: CGSize(width: width, height: 60))
        contentLabel.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: topView, size: nil, offset: CGPoint(x: 5, y: 10))
        footerView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: pictureView, size: CGSize(width: width, height: 44), offset: CGPoint(x: -10, y: 10))
    }
    
    /**
     用于获取行高
     */
    func rowHeight(_ status: Status) -> CGFloat{
        // 1.为了调用 didSet，计算配图高度
        self.status = status
        // 2.强制更新界面
        self.layoutIfNeeded()
        // 3.返回底部视图最大 Y 值
        return footerView.frame.maxY
    }
    
    // MARK: - 懒加载
   
    // 顶部视图
    private lazy var topView : StatusTableViewTopView = StatusTableViewTopView()
    
    /// 正文
    lazy var contentLabel: WHLabel = {
//            let label = WHLabel()
            $0.textColor = UIColor.darkGray
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 20 //限制最大宽度
            return $0
    }(WHLabel())
    
    /// 配图
    lazy var pictureView: StatusPicView = StatusPicView()
    
    // 底部工具条
    lazy var footerView: StatusTableViewBottomView = StatusTableViewBottomView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

