//
//  UserAccount.swift
//  Weibo
//  微信用户信息
//  Created by 王焕 on 16/6/7.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit
import SVProgressHUD

class UserAccount: NSObject, NSCoding {
    
    var access_token: String?
    var expires_in: NSNumber? {
        didSet{
            //根据过期的秒数，生成真正地过期时间
            expires_date = Date(timeIntervalSinceNow: expires_in!.doubleValue)
        }
    }
    var uid: String?
    var expires_date: Date?
    var screen_name: String?
    var avatar_large: String?
    
    init(dict:[String: AnyObject]) {
        super.init()
//        access_token = dict["access_token"] as? String
//        expires_in = dict["expires_in"] as? NSNumber
//        uid = dict["uid"] as? String
        setValuesForKeys(dict) // 字典转模型
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print(key)
    }
    
    override var description: String {
        let properties = ["access_token", "expires_in", "uid", "screen_name", "avatar_large"]
        let dict = self.dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }
    
    func loadUserInfo(_ finished: @escaping (_ account: UserAccount?, _ error:NSError?)->()) {
        assert(access_token != nil, "没有授权")
        
        let path = "2/users/show.json"
        let params = ["access_token": access_token!, "uid": uid!]
        NetworkTools.shareNetworkTools().get(path, parameters: params, progress: nil, success: { (_, JSON) in
            // 1.判断字典是否有值
            if let dict = JSON as? [String: AnyObject] {
                self.screen_name = dict["screen_name"] as? String
                self.avatar_large = dict["avatar_large"] as? String
                // 保存用户信息
//                self.saveAccount()
                finished(self, nil)
            } else {
                finished(nil, nil)
            }
            
            }) { (_, error) in
                print(error)
        }
    }
    
    /**
     返回用户是否已登录
     */
    class func userLogin() -> Bool {
        return UserAccount.loadAccount() != nil
    }
    
    // MARK: - 保存和读取
    static let filePath = "account.plist".cacheDir()
    /**
     保存
     */
    func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.filePath)
    }
    
    /**
     加载
     */
    static var account: UserAccount? // 靜态变量存储，提升性能，防止重复加载
    class func loadAccount() ->  UserAccount? {
        
        // 1.判断是否已经加载过
        if account != nil {
            return account
        }
        // 2.加载授权模型
        account = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? UserAccount
        
        // 3.判断授权信息是否过期，对比升序为过期
        if account?.expires_date?.compare(Date()) == ComparisonResult.orderedAscending {
            // 已经过期
            return nil
        }
        
        return account
    }
    
    // MARK: - NSCoding 
    /**
     编码
     */
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(expires_in, forKey: "expires_in")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(expires_date, forKey: "expires_date")
        aCoder.encode(screen_name, forKey: "screen_name")
        aCoder.encode(avatar_large, forKey: "avatar_large")
    }
    
    /**
     解码
     */
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObject(forKey: "access_token") as? String
        expires_in = aDecoder.decodeObject(forKey: "expires_in") as? NSNumber
        uid = aDecoder.decodeObject(forKey: "uid") as? String
        expires_date = aDecoder.decodeObject(forKey: "expires_date") as? Date
        screen_name = aDecoder.decodeObject(forKey: "screen_name") as? String
        avatar_large = aDecoder.decodeObject(forKey: "avatar_large") as? String
    }
}
