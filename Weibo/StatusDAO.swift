//
//  StatusDAO.swift
//  Weibo
//
//  Created by 王焕 on 2016/11/24.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

// 数据访问层
class StatusDAO: NSObject {
    
    /// 获取微博数据
    class func loadStatuses(since_id: Int, max_id: Int, finished: @escaping ( [[String: Any]]?, _ error: Error? )->() ) {
        // 1.从本地数据库获取数据
        loadCacheStatuses(since_id: since_id, max_id: max_id) { (arr) in
            // 2.如本地有数据，直接返回
            if !arr.isEmpty {
                finished(arr, nil)
                return
            }
        }
        // 3.从网络获取
        let path = "2/statuses/home_timeline.json"
        var params = ["access_token": UserAccount.loadAccount()!.access_token!]
        //下拉刷新
        if since_id > 0 {
            params["since_id"] = "\(since_id)"
        }
        // 上拉加载
        if max_id > 0 {
            params["max_id"] = "\(max_id - 1)"
        }
        NetworkTools.shareNetworkTools().get(path, parameters: params, progress: nil, success: { (_, JSON) in
            // 1.取出statuses key 对应的数组 (存储的都是字典)
            // 2.遍历数组，将字典转换为模型
            let jsonDic = JSON as! [String: Any]
            // 缓存微博数据
            let arr = jsonDic["statuses"] as! [[String: Any]]
            cacheStatuses(statuses: arr)
            finished(arr, nil)
            return
        }) { (_, error) in
            finished(nil, error)
            
        }
        // 4.将从网络获取的数据缓存起来
    }
    
    class func loadCacheStatuses(since_id: Int, max_id: Int, finished: @escaping ( [[String: Any]] )->() ) {
        // 1.定义 sql 语句
        var sql = "SELECT * FROM status "
        if since_id > 0 {
            sql += "WHERE statusId > \(since_id) "
        } else if max_id > 0 {
            sql += "WHERE statusId < \(max_id) "
        }
            sql += "ORDER BY statusId DESC "
            sql += "LIMIT 20; "
        // 2.执行 sql 语句
        var statuses = [[String: Any]]()
        SQLiteManager.shareManager().dbQueue?.inDatabase({ (db) in
            // 2.1查询数据
            let res = db!.executeQuery(sql, withArgumentsIn: nil)
            // 2.2取出查询数据
            while res!.next() {
                // 1.取出数据库存储的微博 json 字符串
                let dictStr = res?.string(forColumn: "statusText")
                // 2.将微博字符串转换为字典
                let data = dictStr!.data(using: .utf8)
                let dict = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                statuses.append(dict as! [String : Any])
            }
        })
        finished(statuses)
    }
    
    /// 缓存微博数据
    ///
    /// - Parameter statuses: 微博数据
    class func cacheStatuses(statuses: [[String: Any]]) {
        // 0.准备数据
        let userId = UserAccount.loadAccount()?.uid
        // 1.定义 sql 语句
        let sql = "INSERT INTO status " +
            "(statusId, statusText, userId) " +
            "VALUES " +
            "(?, ?, ?);"
        
        SQLiteManager.shareManager().dbQueue?.inTransaction({ (db, rollback) in
            for dict in statuses {
                let statusId = dict["id"] as! Int
                // 获取 json 字符串，数组转json
                let data = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let statusText = String(data: data, encoding: .utf8)!
                
                if !db!.executeUpdate(sql, withArgumentsIn: [statusId, statusText, userId!]) {
                    rollback?.pointee = true
                    return
                }
            }
        })
    }
    /// 清空过期的数据
    class func cleanStatuses() {
        //        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en")
        
        let date = Date(timeIntervalSinceNow: -60)
        let dateStr = formatter.string(from: date)
        //        print(dateStr)
        
        // 1.定义SQL语句
        let sql = "DELETE FROM status WHERE createDate  <= '\(dateStr)';"
        
        // 2.执行SQL语句
        SQLiteManager.shareManager().dbQueue?.inDatabase({ (db) -> Void in
            db?.executeUpdate(sql, withArgumentsIn: nil)
        })
    }
}
