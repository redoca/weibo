//
//  PopoverPresentationController.swift
//  Weibo
//  自定义转场动画
//  Created by 王焕 on 16/5/24.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class PopoverPresentationController: UIPresentationController {

    // 定义弹出视图大小
    var presentFrame = CGRect.zero
    /**
     初始化方法，用于创建负责转场动画的对象
     
     - parameter presentedViewController:  被展现的控制器
     - parameter presentingViewController: 发起的控制器 Xcode6 是 nil, Xcode7 是野指针
     
     - returns: 负责转场动画的对象
     */
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        print(presentedViewController)
//        print(presentingViewController)
    }
    
    /**
     即将布局转场子视图时调用
     */
    override func containerViewWillLayoutSubviews() {
        // 1. 修改弹出视图大小
        if presentFrame == CGRect.zero {
            presentedView?.frame = CGRect(x: 100, y: 56, width: 200, height: 200)
        } else {
            presentedView?.frame = presentFrame
        }
        
        // 2. 在容器视图上添加蒙板
        containerView?.insertSubview(coverView, at: 0)
    }
    
    // MARK: - 懒加载
    
    /// 蒙板
    private lazy var coverView: UIView = {
        // 1. 创建蒙板 view
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        view.frame = UIScreen.main.bounds
        
        // 2. 添加监听
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(PopoverPresentationController.close))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    /**
     关闭视图
     */
    func close() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

}
