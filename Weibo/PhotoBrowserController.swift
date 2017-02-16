//
//  PhotoBrowserController.swift
//  Weibo
//
//  Created by 王焕 on 16/7/28.
//  Copyright © 2016年 redoca. All rights reserved.
//

/*
// 1.创建图片浏览器
let vc = PhotoBrowserController(index: indexPath.item, urls: urls)

// 2.显示图片浏览器
present(vc, animated: true, completion: nil)
*/

import UIKit
import SVProgressHUD

private let photoBrowserCellReuseIdentifier = "pictureCell"

class PhotoBrowserController: UIViewController {

    var currentIndex: Int?
    var pictureURLs: [URL]?
    
    init(index: Int, urls: [URL]) {
        
        currentIndex = index
        pictureURLs = urls
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 初始化 UI
        view.backgroundColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        // 2.布局子控件
        collectionView.frame = UIScreen.main.bounds
        closeBtn.xmg_AlignInner(type: XMG_AlignType.bottomLeft, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: 10, y: -10))
        saveBtn.xmg_AlignInner(type: XMG_AlignType.bottomRight, referView: view, size: CGSize(width: 100, height: 35), offset: CGPoint(x: -10, y: -10))
        //设置默认位置
        collectionView.contentOffset = CGPoint(x: CGFloat(currentIndex!) * UIScreen.main.bounds.width, y: 0)
        
        collectionView.dataSource = self
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: photoBrowserCellReuseIdentifier)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 关闭
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // 保存
    func save() {
        // 1.拿到当前显示的cell
        let cell = collectionView.visibleCells.last as! PhotoBrowserCell
        
        let image = cell.iconView.image
        
        // 2.保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // 保存图片到相册
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: Any) {
        if error != nil {
            SVProgressHUD.showError(withStatus: "保存失败")
        } else {
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        }
    }

    // MARK: - 懒加载
    // 关闭
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", for: [])
        btn.setTitleColor(#colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1), for: [])
        btn.backgroundColor = #colorLiteral(red: 0.5296475887, green: 0.5296317339, blue: 0.5296407342, alpha: 1)
        btn.addTarget(self, action: #selector(PhotoBrowserController.close), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    // 保存
    private lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", for: [])
        btn.setTitleColor(#colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1), for: [])
        btn.backgroundColor = #colorLiteral(red: 0.5296475887, green: 0.5296317339, blue: 0.5296407342, alpha: 1)
        btn.addTarget(self, action: #selector(PhotoBrowserController.save), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserLayout())
}

extension PhotoBrowserController : UICollectionViewDataSource, PhotoBrowserCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoBrowserCellReuseIdentifier, for: indexPath) as! PhotoBrowserCell
        
//        cell.backgroundColor = UIColor.randomColor()
        cell.backgroundColor = UIColor.black
        cell.photoBrowserCellDelegate = self
        cell.imageUrl = pictureURLs?[indexPath.item]
        
        return cell
    }
    
    func photoBrowserCellDidClose(cell: PhotoBrowserCell) {
        dismiss(animated: true, completion: nil)
    }
}

class PhotoBrowserLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = UIScreen.main.bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
    }
}
