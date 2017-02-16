//
//  UIImage+Category.swift
//  PhotoSelector
//
//  Created by 王焕 on 2016/11/9.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

extension UIImage {
    /// 根据传入的宽度生成一张图片，按照图片的宽高比来压缩以前的图片
    ///
    /// - Parameter width: 宽度
    func imageWithScale(width: CGFloat) -> UIImage {
        // 1.根据宽度计算高度
        let height = width * size.height / size.width
        
        // 2.按照宽高比绘制一张新图片
        let currentSize = CGSize.init(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        draw(in: CGRect.init(origin: CGPoint.zero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
