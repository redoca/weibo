//
//  StatusTableViewBottomView.swift
//  Weibo
//
//  Created by 王焕 on 16/6/20.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class StatusTableViewBottomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        
        backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        
        addSubview(retweetBtn)
        addSubview(likeBtn)
        addSubview(commonBtn)
        
        xmg_HorizontalTile([retweetBtn, likeBtn, commonBtn], insets: UIEdgeInsets.zero)
    }
    
    // MARK: - 懒加载
    
    // 转发
    private lazy var retweetBtn: UIButton = UIButton.createButton("timeline_icon_retweet", title: "转发")
    // 赞
    private lazy var likeBtn: UIButton = UIButton.createButton("timeline_icon_unlike", title: "赞")
    // 评论
    private lazy var commonBtn: UIButton = UIButton.createButton("timeline_icon_comment", title: "评论")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
