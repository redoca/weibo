//
//  BaseTableViewController.swift
//  Weibo
//
//  Created by 王 焕 on 16/4/25.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, VisitorViewDelegate {

    var userLogin = UserAccount.userLogin() //判断是否已登录
    var visitorView: VisitorView?
    
    override func loadView() {
        userLogin ? super.loadView() : setupVisitorView()
    }
    
    /**
     创建未登录界面
     */
    private func setupVisitorView() {
        // 1.初始化未登录界面
        let customView = VisitorView()
        customView.delegate = self
        view  = customView
        visitorView = customView
        
        // 2.设置导航条未登录
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseTableViewController.registerBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseTableViewController.loginBtnClick))
    }
    
    // MARK: - VisitorViewDelegate 
    func loginBtnClick() {
        print(#function)
        // 1.弹出登录界面
        let oauthVC = OAuthViewController()
        let nav = UINavigationController.init(rootViewController: oauthVC)
        present(nav, animated: true, completion: nil)
    }
    
    func registerBtnClick() {
        print(#function)
    }
}
