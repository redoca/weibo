//
//  User.swift
//  Weibo
//
//  Created by 王焕 on 16/6/16.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class User: BasicModel {
    /// 用户ID
    var id: Int = 0
    /// 友好显示名称
    var name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String? {
        didSet {
            if let urlStr = profile_image_url {
                userHeaderURL = URL(string: urlStr)
            }
        }
    }
    /// 用户头像URL
    var userHeaderURL: URL?
    /// 时候是认证, true是, false不是
    var verified: Bool = false
    /// 用户的认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = -1 {
        didSet {
            switch verified_type {
            case 0:
                verifiedImage = UIImage(named: "avatar_vip")
            case 2, 3, 5:
                verifiedImage = UIImage(named: "avatar_enterprise_vip")
            case 220:
                verifiedImage = UIImage(named: "avatar_grassroot")
            default:
                verifiedImage = nil
            }
        }
    }
    /// 用户的认证图片
    var verifiedImage: UIImage?
    /// 用户会员等级 , 基本数据类型，需有初值
    var mbrank: Int = 0 {
        didSet {
            if mbrank > 0 && mbrank < 7 {
                mbrankImage = UIImage(named: "common_icon_membership_level\(mbrank)")
            }
        }
    }
    var mbrankImage: UIImage?
    
    // 打印当前模型
    var properties = ["id", "name", "profile_image_url", "verified", "verified_type"]
    override var description: String {
        let dict = dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }
}
