//
//  SQLiteManager.swift
//  FMDB_Test
//
//  Created by 王焕 on 2016/11/23.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

class SQLiteManager: NSObject {
    
    fileprivate static let manager: SQLiteManager = SQLiteManager()
    // 单例
    class func shareManager() -> SQLiteManager {
        return manager
    }
//    var db: FMDatabase?
    var dbQueue: FMDatabaseQueue?
    /// 打开数据库
    ///
    /// - Parameter DBName: 数据库名称
    func openDB(_ DBName: String) {
        // 1.数据库路径
        let path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent((DBName as NSString).lastPathComponent)
        print(path)
        // 2.创建数据库对象
//        db = FMDatabase(path: path)
        // 注意: 如果使用 queue 创建 就不用使用 open 打开数据库
        dbQueue = FMDatabaseQueue(path: path)
//        // 3.打开数据库
//        if !db!.open() {
//            print("打开数据库失败")
//            return
//        }
        // 4.创建表
        createTable()
    }
    
    private func createTable() {
        // 1.编写 SQL 语句
        let sql = "CREATE TABLE IF NOT EXISTS status( \n" +
            "statusId INTEGER PRIMARY KEY, \n" +
            "statusText TEXT, \n" +
            "userId INTEGER, \n" +
            "createDate TEXT NOT NULL DEFAULT (datetime('now', 'localtime')) \n" +
            "); \n"
        // 2.执行 SQL 语句 除了 查询 都为之更新
//        if db!.executeUpdate(sql, withArgumentsIn: nil) {
//            print("建表成功")
//        } else {
//            print("建表失败")
//        }
        dbQueue?.inDatabase({ (db) in
            if db!.executeUpdate(sql, withArgumentsIn: nil) {
                print("建表成功")
            } else {
                print("建表失败")
            }
        })
    }
}
