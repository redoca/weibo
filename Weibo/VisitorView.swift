//
//  VisitorView.swift
//  Weibo
//
//  Created by 王 焕 on 16/4/25.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

//Swift 中定义协议需遵守NSObjectProtocol
protocol VisitorViewDelegate: NSObjectProtocol {
    // 登录回调
    func loginBtnClick()
    // 注册回调
    func registerBtnClick()
}

class VisitorView: UIView {
    
    // 定义一个属性保存代理 
    // 一定要加 weak 避免循环引用
    weak var delegate: VisitorViewDelegate?
    
    /**
     设置未登录界面
     
     - parameter isHome:    是否为首页
     - parameter imageName: 图片
     - parameter message:   文本
     */
    func setupVisitorInfo(_ isHome:Bool, imageName: String, message:String) {
        //如果不是首页，就隐藏转盘
        iconView.isHidden = !isHome
        homeIcon.image = UIImage(named: imageName)
        messsageLabel.text = message
        
        //判断是否需要执行动画
        if isHome {
            startAnimation()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //1. 添加子控件
        addSubview(iconView)
        addSubview(iconBgView)
        addSubview(homeIcon)
        addSubview(messsageLabel)
        addSubview(loginBtn)
        addSubview(registerBtn)
       
        //2. 布局子控件
        // 自动布局使用 UIView+AutoLayout.swift
        iconView.xmg_AlignInner(type: XMG_AlignType.center, referView: self, size: nil)
        
        homeIcon.xmg_AlignInner(type: XMG_AlignType.center, referView: self, size: nil)
        
        messsageLabel.xmg_AlignVertical(type: XMG_AlignType.bottomCenter, referView: iconView, size: nil)
        
        // "哪个控件" 的 "什么属性" "等于" "另一控件" 的 "什么属性" 乘以 "多少" 加上 "多少"
        let  widthCons = NSLayoutConstraint(item: messsageLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 222)
        addConstraint(widthCons)
        
        registerBtn.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: messsageLabel, size: CGSize(width: 100, height: 33), offset: CGPoint(x: 0, y: 20))
        
        loginBtn.xmg_AlignVertical(type: XMG_AlignType.bottomRight, referView: messsageLabel, size: CGSize(width: 100, height: 33), offset: CGPoint(x: 0, y: 20))
        
        iconBgView.xmg_Fill(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 如果通过 xib/Stroyboard 创建该类，那么就会崩溃
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 内部控件方法
    private func startAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 20.0
        //代表动画执行完毕移除
        anim.isRemovedOnCompletion = false
        iconView.layer.add(anim, forKey: nil)
    }
    
    func loginBtnClick() {
        delegate?.loginBtnClick()
    }
    
    func registerBtnClick() {
        delegate?.registerBtnClick()
    }
    
    // MARK: - 懒加载控件
    
        /// 转盘
    private lazy var iconView: UIImageView = {
        let iv = UIImageView(image:UIImage(named: "visitordiscover_feed_image_smallicon"))
        return iv
    }()
        /// 图标
    private lazy var homeIcon: UIImageView = {
        let iv = UIImageView(image:UIImage(named: "visitordiscover_feed_image_house"))
        return iv
    }()
        /// 文本
    private lazy var messsageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0;
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.left
        label.text = "asdfjklkjasdlfkjsdkjadslkf"
        return label
    }()
        /// 登录按钮
    private lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.darkGray, for: UIControlState())
        btn.setTitle("登录", for: UIControlState())
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"),
                               for: UIControlState())
        btn.addTarget(self, action: #selector(VisitorView.loginBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
        /// 注册按钮
    private lazy var registerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.darkGray, for: UIControlState())
        btn.setTitle("注册", for: UIControlState())
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"),
                               for: UIControlState())
        btn.addTarget(self, action: #selector(VisitorView.registerBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
        /// 矇板
    private lazy var iconBgView: UIImageView = {
        let iv = UIImageView(image:UIImage(named: "visitordiscover_feed_mask_smallicon"))
        return iv
    }()
}
