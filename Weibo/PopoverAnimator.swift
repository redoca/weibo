//
//  PopoverAnimator.swift
//  Weibo
//
//  Created by 王焕 on 16/5/28.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

let kPopoverWillShow = "kPopoverWillShow"
let kPopoverWillDismiss = "kPopoverWillDismiss"

class PopoverAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning
{
    // 记录 pop 是否展开
    var isPresent: Bool = false
    // 定义弹出视图大小
    var presentFrame = CGRect.zero
    
    // 实现代理方法，告诉系统谁来负责转场动画
    // UIPresentationController iOS8 推出的专门用于负责转场动画的
    @available(iOS 8.0, *)
    func presentationController(forPresentedViewController presented: UIViewController, presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let pc = PopoverPresentationController(presentedViewController: presented, presenting: presenting)
        // 设置菜单大小
        pc.presentFrame = presentFrame
        
        return pc
    }
    
    /**
     谁来负责 Modal 的展现动画
     
     - parameter presented:  被展现的视图
     - parameter presenting: 发起的视图
     - parameter source:
     
     - returns: 谁来负责
     */
    func animationController(forPresentedController presented: UIViewController, presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresent = true
        
        // 发送通知，通知控制器即将展开
        NotificationCenter.default.post(name: Notification.Name(rawValue: kPopoverWillShow), object: self)
        
        return self
    }
    
    /**
     谁来负责 Modal 的消失动画
     
     - parameter dismissed: 被关闭的视图
     
     - returns: 谁来负责
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresent = false
        
        // 发送通知，通知控制器即将关闭
        NotificationCenter.default.post(name: Notification.Name(rawValue: kPopoverWillDismiss), object: self)
        
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    /**
     返回的动画时长
     
     - parameter transitionContext: 上下文，保存动画需要的所有参数
     
     - returns: 动画时长
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /**
     如何动画，无论是展现还是消失都会调用这个文法
     
     - parameter transitionContext: 上下文，保存动画需要的所有参数
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresent { //展开
            // 1.拿到展现视图
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
            
            // 注意，一定要将视图添加到容器上
            transitionContext.containerView.addSubview(toView)
            // 设置锚点
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            
            // 2.执行动画
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                // 2.1清空transform
                toView.transform = CGAffineTransform.identity
                
            }) { (_) in
                // 2.2动画执行完毕,一定要告诉系统
                // 如果不调用可能导至未知异常
                transitionContext.completeTransition(true)
            }
        } else { //关闭
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            UIView.animate(withDuration: transitionDuration(using: transitionContext) * 0.5, animations: {
                // 注意：由于 CGFlout 是不准确的，所以如果写0.0会没有动画
                // 压扁
                fromView.transform = CGAffineTransform(scaleX: 1.0, y: 0.000001)
                }, completion: { (_) in
                    transitionContext.completeTransition(true)
            })
        }
    }
    
}
