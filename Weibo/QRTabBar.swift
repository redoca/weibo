//
//  QRTabBar.swift
//  Weibo
//
//  Created by 王焕 on 16/5/28.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class QRTabBar: UITabBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TabBar
        self.barTintColor = UIColor.black
        self.setItems([qrCodeTabBarItem, barCodeTabBarItem], animated: true)
        // 设置默认
        self.selectedItem = self.items![0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 懒加载
    
    /// 二维码
    private lazy var qrCodeTabBarItem: UITabBarItem = {
        let qrCodeTabBarItem = UITabBarItem(title: "二维码", image: UIImage(named: "qrcode_tabbar_icon_qrcode"), selectedImage: UIImage(named: "qrcode_tabbar_icon_qrcode_highlighted"))
        qrCodeTabBarItem.tag = 1
        return qrCodeTabBarItem
    }()
    
    /// 条形码
    private lazy var barCodeTabBarItem: UITabBarItem = {
        let barCodeTabBarItem = UITabBarItem(title: "条形码", image: UIImage(named: "qrcode_tabbar_icon_barcode"), selectedImage: UIImage(named: "qrcode_tabbar_icon_barcode_highlighted"))
        return barCodeTabBarItem
    }()
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
