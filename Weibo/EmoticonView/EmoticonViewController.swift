//
//  EmoticonViewController.swift
//  Emoticon
//
//  Created by 王焕 on 16/9/9.
//  Copyright © 2016年 王焕. All rights reserved.
//



import UIKit

private let EmoticonReuseCellIdentifier = "EmoticonReuseCellIdentifier"

class EmoticonViewController: UIViewController {

    /// 定义一下闭包属性，用于传递选中的表情模型
    var emoticonDidSelectedCallBack: ((_ emoticon: Emoticon)->())
    
    init(callBack: @escaping (_ emoticon: Emoticon)->()) {
        self.emoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // 初始化UI
        setupUI()
    }
    
    /**
    *  初始化UI
    */
    private func setupUI() {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        // 2.布局子控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 提示：如果想自己封装一个库，就不要依赖第三方
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView": collectionView, "toolBar": toolBar] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-[toolBar(44)]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    /// 切换表情方法
    ///
    /// - parameter item: 表情分类
    func itemClick(item: UIBarButtonItem) {
        collectionView.scrollToItem(at: IndexPath.init(item: 0, section: item.tag), at: UICollectionViewScrollPosition.left, animated: false)
    }
    
    // MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonLayout())
        cv.register(EmotionCell.self, forCellWithReuseIdentifier: EmoticonReuseCellIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return cv
    }()
    
    private lazy var toolBar: UIToolbar = {
        let bar = UIToolbar()
        bar.tintColor = UIColor.darkGray
        var items = [UIBarButtonItem]()
        var index = 0
        for title in ["最近", "默认", "emoji", "浪小花"] {
            let item = UIBarButtonItem.init(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(itemClick(item:)))
            item.tag = index
            index += 1
            items.append(item)
            items.append(UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        bar.items = items
        return bar
    }()
    
    fileprivate lazy var packages: [EmoticonPackage] = EmoticonPackage.packagesList
}

extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 多少组
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    // 告诉系统每组有多少行
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonReuseCellIdentifier, for: indexPath) as! EmotionCell
//        cell.backgroundColor = (indexPath.item % 2 == 0) ? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) : #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // 1.取出对应的组
        let package = packages[indexPath.section]
        // 2.取出对应组对应行的模型 
        let emoticon =  package.emoticons![indexPath.item]
        // 3.赋值给 cell
        cell.emoticon = emoticon
        
        return cell
    }
    
    // 选中 cell 时调用
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        // 1.处理最近表情，将当前使用表情添加到最近表情数组中
        packages[0].appendEmoticons(emoticon: emoticon)
        // 2.回调通知使用者当前点了那个表情
        emoticonDidSelectedCallBack(emoticon)
    }
}

class EmotionCell: UICollectionViewCell {
    var emoticon: Emoticon? {
        didSet{
            // 1.判断是否是图片表情
            if emoticon!.chs != nil {
                iconBtn.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), for: UIControlState.normal)
            } else {
                /// 防止重用
                iconBtn.setImage(nil, for: UIControlState.normal)
            }
            // 2.设置 emoji 表情
            iconBtn.setTitle(emoticon?.emojiStr ?? "", for: UIControlState.normal)
            
            // 3.判断是否是删除按钮
            if emoticon!.isRemoveBtn {
                iconBtn.setImage(#imageLiteral(resourceName: "compose_emotion_delete"), for: UIControlState.normal)
                iconBtn.setImage(#imageLiteral(resourceName: "compose_emotion_delete_highlighted"), for: UIControlState.highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    /// 初始化UI
    private func setupUI() {
        contentView.addSubview(iconBtn)
        iconBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        iconBtn.frame = contentView.bounds.insetBy(dx: 4, dy: 4)
    }
    
    // MARK: - 懒加载
    private lazy var iconBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 自定义布局
class  EmoticonLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        // 1.设置cell相关属性
        let width = (collectionView?.bounds.width)! / 7.0
        itemSize = CGSize.init(width: width, height: width)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        // 2.设置collectionview 相关属性
        collectionView?.isPagingEnabled = true
        collectionView?.bounces  = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        let y = (collectionView!.bounds.height - (3.0 * width)) * 0.49
        collectionView?.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
    }
}
