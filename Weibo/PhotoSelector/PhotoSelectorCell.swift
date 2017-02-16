//
//  PhotoSelectorCell.swift
//  PhotoSelector
//
//  Created by 王焕 on 2016/11/9.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

/*
 在Swift 当中也可以使用 optional 关键字修饰方法，可选方法
 但需在 protocol 前加上 @objc
 */
@objc
protocol PhotoSelectorCellDelegate: NSObjectProtocol {
    @objc optional func photoDidAddSelector(cell: PhotoSelectorCell)
    @objc optional func photoDidRemoveSelector(cell: PhotoSelectorCell)
    
}

class PhotoSelectorCell: UICollectionViewCell {
    
    weak var photoSelectorCellDelegate: PhotoSelectorCellDelegate?
    
    var image: UIImage? {
        didSet {
            if image != nil {
                addBtn.setImage(image, for: UIControlState.normal)
                addBtn.setImage(image, for: UIControlState.highlighted)
                addBtn.isUserInteractionEnabled = false
                removeBtn.isHidden = false
            } else {
                addBtn.setImage(#imageLiteral(resourceName: "compose_pic_add"), for: UIControlState.normal)
                addBtn.setImage(#imageLiteral(resourceName: "compose_pic_add_highlighted"), for: UIControlState.highlighted)
                addBtn.isUserInteractionEnabled = true
                removeBtn.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI() {
        // 1.添加控件
        contentView.addSubview(addBtn)
        contentView.addSubview(removeBtn)
        // 2.布局控件
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[addBtn]-0-|",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["addBtn" : addBtn])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[addBtn]-0-|",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["addBtn" : addBtn])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:[removeBtn]-2-|",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["removeBtn" : removeBtn])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[removeBtn]",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["removeBtn" : removeBtn])
        contentView.addConstraints(cons)
    }
    
    /// 删除图片按钮
    func removeBtnClick() {
        photoSelectorCellDelegate?.photoDidRemoveSelector!(cell: self)
    }
    
    /// 添加按钮
    func addBtnClick() {
        photoSelectorCellDelegate?.photoDidAddSelector!(cell: self)
    }
    
    // MARK: - 懒加载
    private lazy var removeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "compose_photo_close"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(PhotoSelectorCell.removeBtnClick),
                      for: UIControlEvents.touchUpInside)
        btn.isHidden = true
        return btn
    }()
    private lazy var addBtn: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        btn.setImage(#imageLiteral(resourceName: "compose_pic_add"), for: UIControlState.normal)
        btn.setImage(#imageLiteral(resourceName: "compose_pic_add_highlighted"), for: UIControlState.highlighted)
        btn.addTarget(self, action: #selector(PhotoSelectorCell.addBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
}
