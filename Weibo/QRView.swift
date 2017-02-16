//
//  QRView.swift
//  Weibo
//
//  Created by 王焕 on 16/5/29.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class QRView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 添加子控件
        addSubview(bgImgView)
        addSubview(scanlineImgView)
        
        // 布局
        bgImgView.setConstraint()
        scanlineImgView.setConstraint()
        // 执行动画
        startAnimation()
    }
    
    /**
     扫描动画
     */
    func startAnimation() {
        scanlineImgView.yCon.constant = -scanlineImgView.frame.height*1.2
        print(bgImgView.frame.height)
        //执行动画
        let animation = CABasicAnimation(keyPath: "position")
        animation.byValue = NSValue(cgPoint: CGPoint(x: 0, y: scanlineImgView.frame.height * 2))
        animation.duration = 2.0
        animation.repeatCount = MAXFLOAT
        self.scanlineImgView.layer.add(animation, forKey: "positionAnimation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载
    
    // 边框
    private lazy var bgImgView: ConstraintImageView = {
        let bgImgView = ConstraintImageView(image: UIImage(named: "qrcode_border"))
        return bgImgView
    }()
    
    // 扫描波
    lazy var scanlineImgView: ConstraintImageView = {
       let scanlineImgView = ConstraintImageView(image: UIImage(named: "qrcode_scanline_qrcode"))
        return scanlineImgView
    }()
}
