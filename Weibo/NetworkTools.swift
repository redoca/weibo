//
//  NetworkTools.swift
//  Weibo
//
//  Created by 王焕 on 16/6/7.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import AFNetworking

class NetworkTools: AFHTTPSessionManager {

    static let tools:NetworkTools = {
        let url = URL(string: "https://api.weibo.com/")
        let t = NetworkTools(baseURL: url )
        // 设置 AFN 能够接收的数据类型
        t.responseSerializer.acceptableContentTypes = (NSSet(objects:"application/json", "text/json", "text/javascript", "text/plain", "text/html")) as? Set<String>
        return t
    }()
    
    class func shareNetworkTools() -> NetworkTools {
        return tools
    }
    
    /// 发送微博网络方法
    ///
    /// - Parameters:
    ///   - text: 文本
    ///   - image: 图片
    ///   - successCallback: 成功回调
    ///   - failCallback: 失败回调
    ///   - progressCallback: progress回调
    func sendStatus(text: String, image: UIImage?, successCallback: @escaping (_ status: Status)->(),
                    failCallback: @escaping (_ error: Error)->(),  progressCallback: @escaping (_ progress: Progress)->()) {
        if image != nil {
            // 发送图片微博
            let path = "2/statuses/upload.json"
            let params = ["access_token": UserAccount.loadAccount()?.access_token! as AnyObject,
                          "status": text] as [String : Any]
            NetworkTools.shareNetworkTools().post(path, parameters: params, constructingBodyWith: { (formData) in
                // 1.将数据转换为二进制
                let data = UIImagePNGRepresentation(image!)
                // 2.添加图片数据
                /*
                 withFileData 图片二进制数据
                 name 文件上传参数字段名称
                 fileName 文件文，基本随意
                 mimeType MIME 描述消息内容类型的因特网标准 application/octet-stream
                 */
                formData.appendPart(withFileData: data!, name: "pic", fileName: "pic.png", mimeType: "application/octet-stream")
            }, progress: { (progress) in
                progressCallback(progress)
            }, success: { (_, JSON) in
                successCallback(Status(dict: JSON as! [String: AnyObject]))
            }, failure: { (_, error) in
                failCallback(error)
            })
        } else {
            // 发送文字微博
            let path = "2/statuses/update.json"
            let params = ["access_token": UserAccount.loadAccount()?.access_token! as AnyObject,
                          "status": text] as [String : Any]
            NetworkTools.shareNetworkTools().post(path, parameters: params, progress: { (progress) in
                progressCallback(progress)
            }, success: { (_, JSON) in
                successCallback(Status(dict: JSON as! [String: AnyObject]))
            }, failure: { (_, error) in
                failCallback(error)
            })
        }
    }
}
