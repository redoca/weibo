//
//  StatusTableViewTopView.swift
//  Weibo
//
//  Created by 王焕 on 16/6/20.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SDWebImage

class StatusTableViewTopView: UIView {
    
    var status: Status? {
        didSet {
            nameLabel.text = status?.user?.name
            timeLabel.text = status?.created_at
            sourceLabel.text = status?.source
            if let iconUrl = status?.user?.userHeaderURL {
                iconView.sd_setImage(with: iconUrl)
            }
            verifiedView.image = status?.user?.verifiedImage
            vipView.image = status?.user?.mbrankImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconView)
        addSubview(verifiedView)
        addSubview(nameLabel)
        addSubview(vipView)
        addSubview(timeLabel)
        addSubview(sourceLabel)

        iconView.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: self, size: CGSize(width: 40, height: 40), offset: CGPoint(x: 10, y: 10))
        verifiedView.xmg_AlignInner(type: XMG_AlignType.bottomRight, referView: iconView, size: CGSize(width: 14, height: 14), offset: CGPoint(x:5, y:5))
        nameLabel.xmg_AlignHorizontal(type: XMG_AlignType.topRight, referView: iconView, size: nil, offset: CGPoint(x: 10, y: 0))
        vipView.xmg_AlignHorizontal(type: XMG_AlignType.topRight, referView: nameLabel, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 10, y: 0))
        timeLabel.xmg_AlignHorizontal(type: XMG_AlignType.bottomRight, referView: iconView, size: nil, offset: CGPoint(x: 10, y: 0))
        sourceLabel.xmg_AlignHorizontal(type: XMG_AlignType.bottomRight, referView: timeLabel, size: nil, offset: CGPoint(x: 10, y: 0))
    }
    
    // MARK: - 懒加载
    // 头像
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "avatar_default_big"))
    // 认证图标
    private lazy var verifiedView: UIImageView = UIImageView()
    // 昵称
    private lazy var nameLabel: UILabel = UILabel.creatLabel(UIColor.darkGray, fontOfSize: 14)
    /// 会员图标
    private lazy var vipView: UIImageView = UIImageView()
    /// 时间
    private lazy var timeLabel: UILabel = UILabel.creatLabel(UIColor.gray, fontOfSize: 12)
    /// 来源
    private lazy var sourceLabel: UILabel = UILabel.creatLabel(UIColor.gray, fontOfSize: 12)
}
