//
//  NewsFeatureViewController.swift
//  Weibo
//
//  Created by 王焕 on 16/6/15.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reuserIdentifier"

class NewsFeatureViewController: UICollectionViewController {
    
    private let pageCount = 4 // 页面个数
    private var layout: NewfeatureLayout = NewfeatureLayout()
    
    // 因为系统指定的初始化构造方法是带参数的(collectionViewFlowLayout)，而不是不带参数的，所以不用写override
    init() {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.注册一个 Cell
        collectionView?.register(NewfeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: -  UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.获取 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewfeatureCell
        // 2.设置 cell 的数据
        cell.imageIndex = (indexPath as NSIndexPath).item
        // 3.返回 cell 
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // 1.拿到当前显示的 cell 对应的索引
        let path = collectionView.indexPathsForVisibleItems.last!
        
        if (path as NSIndexPath).item == (pageCount - 1) {
            // 2.拿到当前索引对应的 cell
            let cell = collectionView.cellForItem(at: path) as! NewfeatureCell
            // 3.让 cell 执行按钮动画
            cell.startBtnAnimation()
        }
    }
}

/// Swift 中一个文件中可以定义多个类
/// Swift private 同一文件都可访问
/// 如果当前类需要监听按钮的事件，那当前类不可以是私有的
class NewfeatureCell: UICollectionViewCell {
    
    fileprivate var imageIndex: Int? {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex! + 1)")
        }
    }
    
    /**
     按钮动画
     */
    func startBtnAnimation() {
        startBtn.isHidden = false
        
        //执行动画
        startBtn.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        startBtn.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
            // 清空形变
            self.startBtn.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.startBtn.isUserInteractionEnabled = true
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 1.初始化UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1.添加子控制到 ContentView 上
        contentView.addSubview(iconView)
        contentView.addSubview(startBtn)

        // 2.布局子控件的位置
        iconView.xmg_Fill(contentView)
        startBtn.xmg_AlignInner(type: XMG_AlignType.bottomCenter, referView: contentView, size: nil, offset: CGPoint(x: 0, y: -180))
    }
    
    func startBtnClick() {
        // 去主页
        NotificationCenter.default.post(name: Notification.Name(rawValue: SwitchRootViewControllerKey), object: true)
    }
    
    // MARK: - 懒加载
    private lazy var iconView = UIImageView()
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named:"new_feature_button"), for: UIControlState())
        btn.setBackgroundImage(UIImage(named:"new_feature_button_highlighted"),
                               for: UIControlState.highlighted)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(NewfeatureCell.startBtnClick), for: UIControlEvents.touchUpInside)

        return btn
    }()
}

private class NewfeatureLayout: UICollectionViewFlowLayout {
    
    // 准备布局
    // 什么时候调用？ 1.先调用一个有多少行 cell  2.调用准备布局 3.调用返回 cell
    override func prepare() {
        // 1.设置 layout 布局
        itemSize = UIScreen.main.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        // 2.设置 cllectionView 的属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.isPagingEnabled = true
    }
}
