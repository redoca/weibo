//
//  StatusPicView.swift
//  Weibo
//
//  Created by 王焕 on 16/6/20.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SDWebImage

class StatusPicView: UICollectionView {
    
    var status: Status? {
        didSet {
            reloadData()
        }
    }
    
    private var pictureLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    init() {
        super.init(frame:  CGRect.zero, collectionViewLayout: pictureLayout)
    
            register(PicViewCell.self, forCellWithReuseIdentifier: kPicViewCellReuseIdentifier)
            dataSource = self
            delegate = self
            // 设置 cell 之前的间隙
            pictureLayout.minimumInteritemSpacing = 5
            pictureLayout.minimumLineSpacing = 5
            // 设置配图的背景颜色
            backgroundColor = UIColor.white
    }

    /**
     计算配图尺寸
     
     - returns: return value description
     */
    func calculateImageSize() -> CGSize {
        // 1.取出配图个数
        let count = status?.storedPicURLs?.count
        // 2.如果没有配图zero
        if count == 0 || count == nil
        {
            return CGSize.zero
        }
        // 3.如果只有一张配图, 返回图片的实际大小
        if count == 1
        {
            // 3.1取出缓存的图片
            let key = status?.storedPicURLs!.first?.absoluteString
            let image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: key!)
            // 3.2返回缓存图片的尺寸
            pictureLayout.itemSize = (image?.size)!
            return image!.size
        }
        // 4.如果有4张配图, 计算田字格的大小
        let width = 90
        let margin = 5
        pictureLayout.itemSize = CGSize(width: width, height: width)
        if count == 4
        {
            let viewWidth = width * 2 + margin
            return CGSize(width: viewWidth, height: viewWidth)
        }
        
        // 5.如果是其它(多张), 计算九宫格的大小
        /*
         2/3
         5/6
         7/8/9
         */
        // 5.1计算列数
        let colNumber = 3
        // 5.2计算行数
        //               (8 - 1) / 3 + 1
        let rowNumber = (count! - 1) / 3 + 1
        // 宽度 = 列数 * 图片的宽度 + (列数 - 1) * 间隙
        let viewWidth = colNumber * width + (colNumber - 1) * margin
        // 高度 = 行数 * 图片的高度 + (行数 - 1) * 间隙
        let viewHeight = rowNumber * width + (rowNumber - 1) * margin
        return CGSize(width: viewWidth, height: viewHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource

let StatusPicViewSelected = "StatusPicViewSelected" /// 选中图片通知名称
let StatusPicViewIndexKey = "StatusPicViewIndexKey" /// 选中图片索引对应的 key
let StatusPicViewUrlsKey = "StatusPicViewUrlsKey" /// 需要展示的所有图片对应的 key

extension StatusPicView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status?.storedPicURLs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPicViewCellReuseIdentifier, for: indexPath) as! PicViewCell
        
        cell.imageURL = status?.storedPicURLs![(indexPath as NSIndexPath).item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(status?.storedLargePicURLS?[indexPath.item] as Any)
        
        let info = [StatusPicViewIndexKey : indexPath,
                    StatusPicViewUrlsKey : status!.storedLargePicURLS!] as [String : Any]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StatusPicViewSelected), object: self, userInfo: info as [NSObject : AnyObject])
    }
}

private class PicViewCell: UICollectionViewCell {
    
    // 定义属性接收外界传入数据
    var imageURL: URL? {
        didSet {
            // 1.设置图片
            iconImgView.sd_setImage(with: imageURL)
            // 2.判断是否需要显示 gif 图标
            if ((imageURL?.absoluteString)! as NSString).pathExtension.lowercased() == "gif" {
                gifIconView.isHidden = false
            } else {
                gifIconView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImgView)
        iconImgView.addSubview(gifIconView)
        
        iconImgView.xmg_Fill(contentView)
        gifIconView.xmg_AlignInner(type: XMG_AlignType.bottomRight, referView: iconImgView, size: CGSize(width: 30, height: 30))
    }
    
    /// MARK: - 懒加载
    private lazy var iconImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private lazy var gifIconView: UIImageView = {
        let icon = UIImageView(image: #imageLiteral(resourceName: "tableview_loading"))
        icon.isHidden = true
        return icon
    }()
}
