//
//  BasicModel.swift
//  Weibo
//
//  Created by 王焕 on 16/6/16.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit


class BasicModel: NSObject {
    
    // 字典转模型
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    // forUndefinedKey
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
