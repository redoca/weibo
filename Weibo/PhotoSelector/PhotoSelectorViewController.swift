//
//  PhotoSelectorViewController.swift
//  PhotoSelector
//
//  Created by 王焕 on 2016/11/9.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

private let PhotoSelectorCellReuseIdentifier = "PhotoSelectorCellReuseIdentifier"

class PhotoSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        
        // 1.添加子控件
        view.addSubview(collcetionView)
        
        // 2.布局子控件
        collcetionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collcetionView]-0-|",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["collcetionView" : collcetionView])
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collcetionView]-0-|",
                                               options: NSLayoutFormatOptions(rawValue: 0),
                                               metrics: nil, views: ["collcetionView" : collcetionView])
        view.addConstraints(cons)
    }

    // MARK: - 懒加载
    fileprivate lazy var collcetionView: UICollectionView = {
        let clv = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoselectorLayout())
        clv.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        clv.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: PhotoSelectorCellReuseIdentifier)
        clv.dataSource = self
        return clv;
    }()
    
    lazy var pictureImages = [UIImage]()
}

extension PhotoSelectorViewController: UICollectionViewDataSource, PhotoSelectorCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoSelectorCellReuseIdentifier, for: indexPath) as! PhotoSelectorCell
        cell.photoSelectorCellDelegate = self
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.image = pictureImages.count == indexPath.item ? nil : pictureImages[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  pictureImages.count + 1
    }
    
    func photoDidAddSelector(cell: PhotoSelectorCell) {
        /*
         case photoLibrary 照片库，所有照片，拍摄&用 iTunes & iPhoto 同步的照片 - 不能删除
         case camera 相机
         case savedPhotosAlbum 相册自己拍照保存的，可以随意删除
        */
        // 1. 判断是否能够打开照片库
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            print("不能打开相册")
            return
        } else {
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true // 允许用户编辑图片
            present(vc, animated: true, completion: nil)
        }
    }
    
    /// 选中相片之后调用
    ///
    /// - Parameters:
    ///   - picker: picker
    ///   - info: info 图片及信息
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /*
         ⚠️ 一般情况下，只要涉及到从相册中获取图片的功能，都需要处理内存
        一般情况下一个应用程序启动会占用 20M 左右的内存， 当内存飙升到 500M 左右的时侯系统就会发送内存警告，
         此时就需要释放内存，否则会闪退
         只要内存释放到100M 左右，那么系统就不会闪退我们的应用程序
         也就是说一个应用程序占用内存20~100M时是比较安全的范围
        */
        
        /*
        info["UIImagePickerControllerOriginalImage"] 原始图片
        info["UIImagePickerControllerEditedImage"] 编辑后的图片
        */
        // 1.将当前选中的图片添加到数组中
//        let data1 = UIImageJPEGRepresentation(image, 0.2) // JPEG 压缩图片是不保真的，JPG图片解压时非常消耗性能
        let image = info["UIImagePickerControllerEditedImage"] as! UIImage
        let newImage = image.imageWithScale(width: 300)
        pictureImages.append(newImage)
        collcetionView.reloadData()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func photoDidRemoveSelector(cell: PhotoSelectorCell) {
        // 1.从数组中移除当前点按的图片
        let indexPath = collcetionView.indexPath(for: cell)
        pictureImages.remove(at: indexPath!.item)
        // 2.刷新表格
        collcetionView.reloadData()
    }
}

class PhotoselectorLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = CGSize(width: 80, height: 80)
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
    }
}
