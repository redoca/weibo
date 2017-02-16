//
//  String+Category.swift
//  Weibo
//
//  Created by 王焕 on 16/6/7.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

extension String {
    /**
     将当前自符串拼接到 Cache 目录后面
     */
    func cacheDir() -> String {
        let filePath = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent((self as NSString).lastPathComponent)
        return filePath
    }

    /**
     将当前自符串拼接到 Document 目录后面
     */
    func docDir() -> String {
        let filePath = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString).appendingPathComponent((self as NSString).lastPathComponent)
        return filePath
    }
    
    /**
     将当前自符串拼接到 Temp 目录后面
     */
    func tmpDir() -> String {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((self as NSString).lastPathComponent)
        return filePath
    }
}
