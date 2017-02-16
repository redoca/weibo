//
//  MainViewController.swift
//  Weibo
//
//  Created by 王 焕 on 16/3/18.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加子控制器
        addChildViewControllers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //添加加号按钮
        setupComposeBtn()
    }
    
    private func setupComposeBtn() {
        //1 添加加号按钮
        tabBar.addSubview(composeBtn)
        //2 调整加号按钮位置
        let width = UIScreen.main.bounds.size.width / CGFloat((viewControllers?.count)!)
        let rect = CGRect(x: 0, y: 0, width: width, height: 49)
        composeBtn.frame = rect.offsetBy(dx: 2 * width, dy: 0)
    }
    
    /**
     添加子控制器
     */
    private func addChildViewControllers() {
        //获取json文件的路径
        if let path = Bundle.main.path(forResource: "Main.json", ofType: nil) {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                do {
                    let dictArr = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    for dict in dictArr as! [[String: String]] {
                        addChildViewController(dict["vcName"]!, title: dict["title"]!, imageName: dict["imageName"]!)
                    }
                }catch {
                    print(error)
                    
                    addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
                    addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
                    addChildViewController("DiscoverTableViewController", title: "广场", imageName: "tabbar_discover")
                    addChildViewController("ProfileTableViewController", title: "我", imageName: "tabbar_profile")
                }
            }
        }
    }
    
    /**
     初始化了控制器
     
     - parameter childControllerName: 需要初始化的子控制器名称
     - parameter title:               子控制器的标题
     - parameter imageName:           子控制器的图片
     */
    private func addChildViewController(_ childControllerName: String,
                                        title: String, imageName: String) {
        
        //动态获取命名空间
        let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        let childController = (NSClassFromString(nameSpace + "." + childControllerName) as! UIViewController.Type).init()
        
        childController.tabBarItem.image = UIImage(named: imageName)
        childController.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        childController.title = title
        
        let nav = UINavigationController(rootViewController: childController)
        addChildViewController(nav)
    }
    
    
    /**
     加号事件，发微博界面
     */
    func composeBtnClick() {
        // 判断是否已登录
        if UserAccount.userLogin() {
            // 弹出发微博界面
            let composeVC = ComposeViewController()
            let nav = UINavigationController(rootViewController: composeVC)
            present(nav, animated: true, completion: nil)
        } else {
            // 弹出登录界面
            let oauthVC = OAuthViewController()
            let nav = UINavigationController.init(rootViewController: oauthVC)
            present(nav, animated: true, completion: nil)
        }
    }
    
    //懒加载 ＋
    private lazy var composeBtn: UIButton = {
        let btn = UIButton()
        //前景图片
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), for: UIControlState())
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), for: UIControlState.highlighted)
        //背景图片
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), for: UIControlState())
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), for: UIControlState.highlighted)
        
        btn.addTarget(self, action: #selector(MainViewController.composeBtnClick), for: .touchUpInside)
        
        return btn
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
