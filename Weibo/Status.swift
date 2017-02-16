//
//  Status.swift
//  Weibo
//
//  Created by 王焕 on 16/6/15.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SDWebImage

class Status: BasicModel {
    /// 微博创建时间
    var created_at: String? {
        didSet{
            // created_at = "Sun Sep 12 14:50:57 +0800 2014"
            
            // 1.将字符串转换为时间
            let createdDate = Date.dateWithStr(created_at!)
            // 2.获取格式化之后的时间字符串
            created_at = createdDate.descDate
        }
    }
    /// 微博ID
    var id: Int = 0
    /// 微博信息内容
    var text: String? 
    /// 微博来源
    var source: String? {
        didSet {
            // 1.截取字符串
            if let str = source , source != "" {
                    // 1.1获取截取的开始截取的位置
                    let startLocation = (str as NSString).range(of: ">").location + 1
                    // 1.2获取截取的长度
                    let lenght = (str as NSString).range(of: "<", options: NSString.CompareOptions.backwards).location - startLocation
                    // 1.3截取字符串
                    source = "来自: " + (str as NSString).substring(with: NSMakeRange(startLocation, lenght))
            }
        }
    }
    /// 用户模型
    var user: User?
    /// 转发微博数据
    var retweeted_status: Status?
    /// 1.配图数组
    var pic_urls: [[String: Any]]? {
        didSet {
            storedPicURLs = [URL]()
            storedLargePicURLS = [URL]()
            for dict in pic_urls! {
                if let urlStr = dict["thumbnail_pic"] as? String {
                    // 缩略图
                    storedPicURLs?.append(URL(string: urlStr)!)
                    // 处理大图 缩略图与大图区别于地址
                    let largeURLStr = urlStr.replacingOccurrences(of: "thumbnail", with: "large")
                    storedLargePicURLS?.append(URL(string: largeURLStr)!)
                }
            }
        }
    }
    /// 2.配图URL数组
    var storedPicURLs: [URL]?
    /// 2.配图大图URL数组
    var storedLargePicURLS: [URL]?
    /// 3.定义一个计算属性，用于返回原创或者转发配图的 URL 数组
    var pictureURLs:[URL]? {
        return retweeted_status != nil ? retweeted_status?.storedPicURLs :storedPicURLs
    }
    /// 3.定议一个计算属性，用于返回原创或者转发配图大图的的 URL 数组
    var largePictureURLS:[URL]? {
        return retweeted_status != nil ? retweeted_status?.storedLargePicURLS :storedLargePicURLS
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if "user" == key { // 用户数据
            user = User(dict: value as! [String: AnyObject])
            return
        }
        if "retweeted_status" == key { // 转发微博数据
            retweeted_status = Status(dict: value as! [String: AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }
    
    // 打印当前模型
    var properties = ["created_at", "id", "text", "source", "pic_urls"]
    override var description: String {
        let dict = dictionaryWithValues(forKeys: properties)
        return "\(dict)"
    }
}

extension Status {
    /**
     加载微博数据
     
     - parameter finished: 返回闭包，将 模型 数组返回
     */
    class func loadStatuses(since_id: Int, max_id: Int, finished:@escaping (_ models:[Status]?, _ error: Error?) -> ()) {
//        let path = "2/statuses/home_timeline.json"
//        var params = ["access_token": UserAccount.loadAccount()!.access_token!]
//        StatusDAO.loadCacheStatuses(since_id: since_id, max_id: max_id)
//        //下拉刷新
//        if since_id > 0 {
//            params["since_id"] = "\(since_id)"
//        }
//        // 上拉加载
//        if max_id > 0 {
//            params["max_id"] = "\(max_id - 1)"
//        }
//        
//        NetworkTools.shareNetworkTools().get(path, parameters: params, progress: nil, success: { (_, JSON) in
//            // 1.取出statuses key 对应的数组 (存储的都是字典)
//            // 2.遍历数组，将字典转换为模型
//            let jsonDic = JSON as! [String: Any]
//            // 缓存微博数据
//            StatusDAO.cacheStatuses(statuses: jsonDic["statuses"] as! [[String: Any]])
//            let models = dict2Model(jsonDic["statuses"] as! [[String: Any]])
//            // 3.缓存微博配图
//            cacheStatusImages(models, finished: finished)
//            }) { (_, error) in
//                finished(nil, nil)
//        }
        
        StatusDAO.loadStatuses(since_id: since_id, max_id: max_id) { (arr, error) in
            if arr == nil {
                finished(nil, error)
                return
            }
            if error != nil {
                finished(nil, error)
                return
            }
            let models = dict2Model(arr!)
            cacheStatusImages(models, finished: finished)
        }
    }
    
    /**
     缓存图片, 回调 finish
     
     - parameter list: 数据
     */
    class func cacheStatusImages(_ list: [Status], finished:@escaping (_ models:[Status]?, _ error: NSError?) -> ()) {
        // 判断此次是否有新微博
        if list.count == 0 {
            finished(list, nil)
            return
        }
        // 0. 创建一个组
        let group = DispatchGroup()
        // 1.缓存图片
        for status in list {
            // 1.1 判断当前微博是否有配图，如果没有就直接跳过
            if status.pictureURLs == nil {
                continue
            }
            
            for url in status.pictureURLs! {
                // 将当前下载操作添加到组中
                group.enter()
                
                SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, _, _, _, _) in
                    // 缓存成功
                    // 离开当前组
                
                    group.leave()
                })
            }
        }
        // 2.图片下载完毕，通知调用者, 组中全都完成通知，进入主进程
        group.notify(queue: DispatchQueue.main) {
            // 能够来到这个地方，一定是所有图片都下载完毕
            finished(list, nil)
        }
    }
    
    // 字典数组转换为模型数组
    class func dict2Model(_ list: [[String: Any]]) -> [Status] {
        var models = [Status]()
        for dict in list {
            models.append(Status(dict:dict))
        }
        return models
    }
}
