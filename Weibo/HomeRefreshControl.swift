//
//  HomeRefreshControl.swift
//  Weibo
//
//  Created by 王焕 on 16/7/1.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class HomeRefreshControl: UIRefreshControl {

    override init() {
        super.init()
        
        setupUI()
    }
    
    private func setupUI() {
        
        // 1.添加子控件
        addSubview(refreshView)
        
        // 2.布局子控件
        refreshView.xmg_AlignInner(type: XMG_AlignType.center, referView: self,
                                   size: CGSize(width: 170, height: 60))
        
        /*
         1. 当用户下拉到一定程度的时候需要旋转箭头
         2. 当用户上推到一定程度需要旋转箭头
         3. 当下拉刷新控件触发刷新方法的时侯，需要显示刷新界面
         */
        
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    ///定义变量记录是否需要旋转
    private var rotationArrowFlag = false
    
    ///定义变更记录当前是滞正在执行圈圈动画
    private var loadingViewAnimFlag = false
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 过滤掉不需要的数据
        if frame.origin.y >= 0 {
            return
        }

        // 判断是否已经触发刷新事件
        if isRefreshing && !loadingViewAnimFlag {
            // 显示圈圈
            loadingViewAnimFlag = true
            refreshView.startLoadingViewAnim()
            return
        }

        if frame.origin.y >= -50 && rotationArrowFlag {
            // 翻转回来
            rotationArrowFlag = false
            refreshView.rotaionArrowIcon(flag: rotationArrowFlag)
        } else if frame.origin.y < -50 && !rotationArrowFlag {
            // 翻转
            rotationArrowFlag = true
            refreshView.rotaionArrowIcon(flag: rotationArrowFlag)
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        // 关闭圈圈动画
        refreshView.stopLoadingViewAnim()
        //复位圈圈动画标记
        loadingViewAnimFlag = false
    }
    
    // MARK: - 懒加载
    public lazy var refreshView: HomeRefreshView = HomeRefreshView.refreshView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "frame")
    }
}

class HomeRefreshView : UIView {
    
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var arrowIcon: UIImageView!
    
    // 旋转箭头
    func rotaionArrowIcon(flag: Bool) {
        var angle = M_PI
        angle += flag ? -0.01 : 0.01
        UIView.animate(withDuration: 0.2) { 
            self.arrowIcon.transform = self.arrowIcon.transform.rotated(by: CGFloat(angle))
        }
    }
    
    /**
     开始圈圈动画
    */
    func startLoadingViewAnim() {
        
        tipView.isHidden = true
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 1.0
        //代表动画执行完毕移除
        anim.isRemovedOnCompletion = false
        loadingView.layer.add(anim, forKey: nil)
    }
    
    /**
     停止圈圈动画
     */
    func stopLoadingViewAnim() {
        tipView.isHidden = false
        loadingView.layer.removeAllAnimations()
    }
    
    class func refreshView()  -> HomeRefreshView {
        return Bundle.main.loadNibNamed("HomeRefreshView", owner: nil, options:nil)!.last as! HomeRefreshView
    }
    
}
