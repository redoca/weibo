//
//  PhotoBrowserCell.swift
//  Weibo
//
//  Created by 王焕 on 16/8/26.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoBrowserCellDelegate: NSObjectProtocol {
    func photoBrowserCellDidClose(cell: PhotoBrowserCell)
}

class PhotoBrowserCell: UICollectionViewCell {
    
    weak var photoBrowserCellDelegate : PhotoBrowserCellDelegate?
    
    var imageUrl: URL? {
        didSet {
            
            // 1.重置属性
            reset()
            
            // 2.显示菊花
            activity.startAnimating()
            
            // 3.设置图片
            iconView.sd_setImage(with: imageUrl) { (image, _, _, _) in
                // 4.隐藏菊花
                self.activity.stopAnimating()
                // 5.调整图片的尺寸和位置
                self.setImageViewPostion()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 1.初始化 UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1.添加子控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(iconView)
        contentView.addSubview(activity)
        
        // 2.布局控件
        activity.center = contentView.center
        
        // 3.监听图片点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(PhotoBrowserCell.close))
        iconView.addGestureRecognizer(tap)
        iconView.isUserInteractionEnabled = true
    }
    
    /**
     点击关闭
    */
    func close() {
        photoBrowserCellDelegate?.photoBrowserCellDidClose(cell: self)
    }
    
    /**
     调整图片显示的位置，判断长短图
     */
    private func setImageViewPostion() {
        // 1.拿到按照宽高比计算之后的图片大小
        let size = self.displaySize(image: iconView.image!)
        // 2.判断图片的高度，是否大于屏幕的高度
        if size.height > UIScreen.main.bounds.height {
            // 2.1大于 长图
            iconView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            
        } else {
            // 2.2小于 短图
            iconView.frame = CGRect(origin: CGPoint.zero, size: size)
            // 处理居中显示
            let y = (UIScreen.main.bounds.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
        }
    }
    
    /**
     重置 scrollView 和 imageView 的属性
     */
    private func reset() {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = CGSize.zero
        
        iconView.transform = CGAffineTransform.identity
    }
    
    /*＊
     按图片的宽高比计算图片显示的大小
     */
    private func displaySize(image : UIImage) -> CGSize {
        // 1.拿到图片的宽高比
        let scale = image.size.height / image.size.width
        // 2.根据宽高比计算高度
        let width = UIScreen.main.bounds.width
        let height = width * scale
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - 懒加载
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = UIScreen.main.bounds
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.5
        
        return scrollView
    }()
    lazy var iconView: UIImageView = UIImageView()
    private lazy var activity: UIActivityIndicatorView =  UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
}

extension PhotoBrowserCell: UIScrollViewDelegate {
    // 告诉系统需要缩放的控件
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return iconView
    }
    
    // 缩放结束，重新调整配图的位置
    // view 被缩放的视图
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        // 注意：缩放的本质是修改 transfrom，而修改transfrom 不会影响到 bounds, 只有 frame 会受到影响
        var offsetX = (UIScreen.main.bounds.width - view!.frame.width) * 0.5
        var offsetY = (UIScreen.main.bounds.height - view!.frame.height) * 0.5
        print("offsetX = \(offsetX), offsetY = \(offsetY)")
        
        offsetX = offsetX < 0 ? 0 : offsetX
        offsetY = offsetY < 0 ? 0 : offsetY
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
