
//
//  HomeTableViewController.swift
//  Weibo
//
//  Created by 王 焕 on 16/3/18.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

let kHomeReuseIdentifier = "kHomeReuseIdentifier"

class HomeTableViewController: BaseTableViewController {
    
    // 保存微博数组
    var statuses: [Status]? {
        didSet {
            // 设置完毕数据进行刷新
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.如果没有登录，就设置未登录界面
        if !userLogin {
            visitorView?.setupVisitorInfo(true, imageName: "visitordiscover_feed_image_house",
                                          message: "关注一些人，回这里看看有什么惊喜")
            return
        }
        
        // 2.初始化导航条
        setupNav()
        
        // 3.注册通知，监听菜单
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.titleBtnChange), name: NSNotification.Name(rawValue: kPopoverWillShow), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.titleBtnChange), name: NSNotification.Name(rawValue: kPopoverWillDismiss), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.showPhotoBrowser), name: NSNotification.Name(rawValue: StatusPicViewSelected), object: nil)
        
        // 4.注册 cell
        tableView.register(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.NormalCell.rawValue)
        tableView.register(StatusForwardTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.ForwardCell.rawValue)
        
//        tableView.estimatedRowHeight = 200 //预估行高
//        tableView.rowHeight = UITableViewAutomaticDimension //自动调整尺寸
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // 5.添加下拉刷新微博
        refreshControl = HomeRefreshControl()
        refreshControl?.addTarget(self, action: #selector(HomeTableViewController.loadData), for: UIControlEvents.valueChanged)
        
//        let refreshView = UIView()
//        refreshView.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.009361755543, alpha: 1)
//        refreshView.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
//        refreshControl?.addSubview(refreshView)
//        refreshControl?.addTarget(self, action: #selector(HomeTableViewController.loadData), for: UIControlEvents.valueChanged)
//        refreshControl?.endRefreshing()

        // FIXME: - iOS 10 not work
//        self.navigationController?.navigationBar.insertSubview(newStatusLabel, at: 0)
        
        // 6.加载微博数据
        loadData()
    }
    
    /**
     设置Nav
     */
    private func setupNav() {
        // 1.左边按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem.creatBarButtonItem("navigationbar_friendattention", target: self, action: #selector(HomeTableViewController.leftItemClick))
        // 2.右边按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem.creatBarButtonItem("navigationbar_pop", target: self, action: #selector(HomeTableViewController.rightItemClick))
        
        // 3.初始化标题按钮
        let titleBtn = TitleButton()
        titleBtn.setTitle("Redoca ", for: UIControlState())
        titleBtn.addTarget(self, action: #selector(HomeTableViewController.titleBtnClick(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    /**
     Nav 标题事件
     
     - parameter btn: 标题按钮
     */
    func titleBtnClick(_ btn: TitleButton) {
        // 1. 修改箭头方向
//        btn.selected = !btn.selected
        // 2. 弹出菜单
        let sb = UIStoryboard(name: "PopoverViewController", bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: "PopoverViewController")
    
        // 默认情况下modal会移除以前控制器的 view ，替换为当前弹出的 view
        // 使用自定义转场，不会移除以前的 view
        // 2.1 设置转场代理
        vc.transitioningDelegate = popAnimator
        // 2.2 设置转场样式
        vc.modalPresentationStyle = UIModalPresentationStyle.custom
        present(vc, animated: true, completion: nil)
    }
    
    /**
     
     */
    private func showNewStatusCount(count: Int) {
        newStatusLabel.isHidden = false
        newStatusLabel.text = (count == 0) ? "没有刷新到新的微博" : "刷新到\(count)条微博"
//        let rect = newStatusLabel.frame
//        UIView.animate(withDuration: 2, animations: {
////            UIView.setAnimationRepeatAutoreverses(true) //会有闪现Bug
//            self.newStatusLabel.frame = rect.offsetBy(dx: 0, dy: 3 * rect.height)
//            }) { (_) in
//            self.newStatusLabel.frame = rect
//        }
        UIView.animate(withDuration: 1.5, animations: {
            self.newStatusLabel.transform = CGAffineTransform(translationX: 0, y: self.newStatusLabel.frame.height)
            }) { (_) in
                UIView.animate(withDuration: 1.5, animations: {
                    self.newStatusLabel.transform = CGAffineTransform.identity
                    }, completion: { (_) in
                        self.newStatusLabel.isHidden = true
                })
        }
    }
    
    /**
     修改标题按钮状态
    */
    func titleBtnChange() {
        
        let btn = navigationItem.titleView as! TitleButton
        btn.isSelected = !btn.isSelected
    }
    
    /**
     左侧事件
     */
    func leftItemClick() {
        print(#function)
    }
    
    /**
     右侧按钮事件 二维码
     */
    func rightItemClick() {
        print(#function)
        
        let navController = UINavigationController.init(rootViewController: QRCodeViewController())
        present(navController, animated: true, completion: nil)
    }
    
    /// 定议变更记录当前是上拉还是下拉
    var pullupRefreshFlag = false
    /**
     获取微博数据
     如果想调用一个私有的方法：
     1. 去掉private
     2. 或者在前加 @objc 当做 OC 方法来处理
     */
    @objc fileprivate func loadData() {
        
        /*
         1.默认最新返回20条数据
         2.since_id : 会返回比 since_id 大的微博
         3.max_id : 会返回小于等于 max_id 的微博
         
         每条微博都有一微博 ID， 而且微博 ID 越后面发送的微博，它的微博 ID 越大递增
         
         新浪返回给我们的微博数据，是从大到小返回给我们的
        */
        var since_id = statuses?.first?.id ?? 0
        
        var max_id = 0
        
        if pullupRefreshFlag {
            since_id = 0
            max_id = statuses?.last? .id ?? 0
            pullupRefreshFlag = false
        }
        
        Status.loadStatuses(since_id: since_id, max_id : max_id) { (models, error) in
            self.refreshControl?.endRefreshing()
            if error == nil { // 如果无误，填加数据
                if since_id > 0 { //下拉刷新，非第一次请求
                    self.statuses = models! + self.statuses!
                    self.showNewStatusCount(count: models?.count ?? 0)
                } else if max_id > 0 {
                    self.statuses = self.statuses! + models!
                } else { // 第一次请求
                    self.statuses = models
                }
            } else { //如果有误，不处理
                return
            }
        }
    }
    
    /**
     显示图片浏览器通知方法
     */
    func showPhotoBrowser(notify: Notification) {
        print(notify.userInfo ?? "")
        
        guard let indexPath = notify.userInfo![StatusPicViewIndexKey] as! IndexPath! else {
            print("没有indexPath")
            return
        }
        
        guard let urls = notify.userInfo![StatusPicViewUrlsKey] as? [URL] else {
            print("没有匹配")
            return
        }
        
        // 1.创建图片浏览器
        let vc = PhotoBrowserController(index: indexPath.item, urls: urls)
        
        // 2.显示图片浏览器
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - 懒加载
    /// 转场动画 一定要自定一个属性来保存自定义转场动画
    private lazy var popAnimator: PopoverAnimator = {
        let pop = PopoverAnimator()
        pop.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 300)
        return pop
    }()
    
    // 下拉刷新提示信息
    private lazy var newStatusLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.9559464455, green: 0.7389599085, blue: 0.2778314948, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        let height = 44
//        label.frame = CGRect(x: 0, y: -2 * height, width: Int(UIScreen.main().bounds.width) , height: height)
        label.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width) , height: height)
        label.isHidden = true
        return label
    }()
    
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    // 行高缓存字典， key 就是微博ID， 值为行高
    var rowCache: [Int: CGFloat] =  [Int: CGFloat]()
    
    override func didReceiveMemoryWarning() {
        rowCache.removeAll()
    }
}

extension HomeTableViewController {
    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let status = statuses![(indexPath as NSIndexPath).row]

        let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCellIdentifier.cellID(status), for: indexPath) as! StatusTableViewCell
        
        cell.status = status
        
        //判断是后滚动到了最后一个 cell 
        if indexPath.row == ((statuses?.count ?? 0) - 1) {
            pullupRefreshFlag = true
            loadData()
        }
       
        return cell
    }
    
    // 返回行高
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 1.取出对应行的模型
        let status = statuses![(indexPath as NSIndexPath).row]
        
        // 取缓存中的行高
        if let height = rowCache[status.id] {
            return height
        }
        // 2.拿到 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCellIdentifier.cellID(status)) as! StatusTableViewCell
        // 3.拿到对应行高
        let rowHeight = cell.rowHeight(status)
        
        // 缓存行高
        rowCache[status.id] = rowHeight
        
        return rowHeight
    }
}
