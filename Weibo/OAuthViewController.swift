//
//  OAuthViewController.swift
//  Weibo
//
//  Created by 王焕 on 16/6/7.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SVProgressHUD

class OAuthViewController: UIViewController {

    let WBAppKey = "3130780322"
    let WBAppSecret = "1159c1f3366e27acb9752cfeb02c0bfb"
    let WBRedirectUri = "http://www.xuhaisoft.com"
    
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 0.初始化导航条
        navigationItem.title = "围脖"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "关闭",
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(OAuthViewController.close))
        
        // 1.获取未授权的 RequestToken
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBRedirectUri)"
        let url = URL(string: urlStr)
        let request = URLRequest.init(url: url!)
        webView.loadRequest(request)
    }
    
    /**
     关闭此页
     */
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 懒加载
    private lazy var webView: UIWebView = {
        let wv = UIWebView()
        wv.delegate = self
        return wv
    }()
}

extension OAuthViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 1.判断是否是授权回调页面，如果不是就继续加载
        let urlStr  = request.url!.absoluteString
        if !(urlStr.hasPrefix(WBRedirectUri)) {
            // 继续加载
            return true
        }
        print(urlStr)
        // 2.判断是否授权成功
        let codeStr = "code="
        if request.url!.query!.hasPrefix(codeStr) {
            // 授权成功,取出已经授权的RequestToken
            let code    = request.url?.query?.substring(from: codeStr.endIndex)
            loadAccessToken(code!)
            
        } else {
            // 取消授权
            close()
        }
        return false
    }
    
    /**
     获取授权 Token
     
     - parameter code: 授权回调 code
     */
    private func loadAccessToken(_ code: String) {
        // 1.定义路径
        let path = "oauth2/access_token"
        // 2.封装参数
        let params = ["client_id": WBAppKey,
                      "client_secret": WBAppSecret,
                      "grant_type": "authorization_code",
                      "code": code,
                      "redirect_uri": WBRedirectUri]
        // 3.网络请求
        NetworkTools.shareNetworkTools().post(path, parameters: params, progress: nil, success: { (_, JSON) in
          
            // 1.字典转模型
            let account = UserAccount(dict: JSON as! [String: AnyObject])
            // 2.获取用户信息
            account.loadUserInfo({ (account, error) in
                // 3.归档授权信息
                if account != nil {
                    account?.saveAccount() //保存模型
                    //去欢迎界面
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SwitchRootViewControllerKey), object: false)
                } else {
                    SVProgressHUD.show(withStatus: "网络不给力...")
                }
            })
            
            SVProgressHUD.dismiss()
            self.close()
            }) { (_, error) in
                print(error)
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        // 提示用户正在加载
        SVProgressHUD.show(withStatus: "正在加载...")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 关闭提示
        SVProgressHUD.dismiss()
    }
}
