//
//  EmoticonPackage.swift
//  Emoticon
//
//  Created by 王焕 on 2016/9/28.
//  Copyright © 2016年 王焕. All rights reserved.
//

/*
 结构：
 1. 加载Emoticons.plist 拿到每组表情的路径
 Emoticons.plist(字典)  存储了所有组表情的数据
 |---packages 字典数组
     |---id 存储了对应组表情对应文件夹
 
 2. 根据拿到的路径加载对应表情的 info.plist
 info.plist(字典)
 |---id 当前组表情文件夹的名称
 |---group_name_cn 组的名称
 |---emoticons 字典数组，里面存储了所有表情
     |---chs 文字
     |---png 图片
     |---code emoji 表情对应的16制字符串
 */

import UIKit

class EmoticonPackage: NSObject {
    var id: String? ///当前组表情文件夹的名称
    var group_name_cn: String? ///组的名称
    var emoticons: [Emoticon]? ///字典数组，里面存储了所有表情
    
    // 提升性能，只加载一次表情
    static let packagesList:[EmoticonPackage] = EmoticonPackage.loadPackages()
    
    init(id: String) {
        self.id = id
    }
    /// 获取所有组的表情数组
    ///
    /// - returns: 表情数组
    private class func loadPackages() -> [EmoticonPackage] {
        
        var packages = [EmoticonPackage]()

        // 0.创建最近使用组
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [Emoticon]()
        pk.appendEmptyEmoticons()
        packages.append(pk)
        
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 1.加载 emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        // 2.或 emoticons 中获取 packages
        let dictArr = dict["packages"] as! [[String: Any]]
        // 3.遍历 packages 数组
        for d in dictArr {
            // 4.取出 ID
            let package = EmoticonPackage(id: d["id"]! as! String)
            packages.append(package)
            package.loadEmoticons()
            package.appendEmptyEmoticons()
        }
        return packages
    }
    
    /// 加载每一组中所有表情
    func loadEmoticons() {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath())
        group_name_cn = emoticonDict?["group_name_cn"] as? String
        let dictArr =  emoticonDict?["emoticons"] as! [[String: String]]
        emoticons = [Emoticon]()
        var index = 0   /// 每页添加 del 按钮
        for dict in dictArr {
            if index == 20 {
                emoticons?.append(Emoticon(isRemoveBtn: true))
                index = 0
            }
            emoticons?.append(Emoticon(dict: dict, id: id!))
            index = index + 1
        }
    }
    
    /// 追加空白按钮
    func appendEmptyEmoticons() {
        let count = emoticons!.count % 21
        for _ in count..<20 {
            // 追加空白按钮
            emoticons?.append(Emoticon(isRemoveBtn: false))
        }
        /// 追加删附按钮
        emoticons?.append(Emoticon(isRemoveBtn: true))
    }
    
    /// 添加最近表情
    func appendEmoticons(emoticon: Emoticon) {
        // TODO: - 显示不及时问题，有待解决
        if emoticon.isRemoveBtn { //不是 del 按钮才添加
            return
        } else {
            emoticon.times += 1
        }
        
        let contains = emoticons!.contains(emoticon)
        if !contains {
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }
        
        // 3.对数组进行排度
        var result = emoticons?.sorted(by: { (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        
        // 4.删除多余的表情
        if !contains {
            result?.removeLast()
            result?.append(Emoticon(isRemoveBtn: true))
        }
        emoticons = result    
    }
    
    /// 获取指定文件的全路径
    ///
    /// - parameter fileName: 文件名称
    ///
    /// - returns: 全路径
    func infoPath() -> String {
        return EmoticonPackage.emoticonPath().appending("/\(id!)/info.plist")
    }
    
    /// 获取表情的主路径
    class func emoticonPath() -> String {
        return Bundle.main.bundlePath.appending("/Emoticons.bundle")
    }
}

class Emoticon: NSObject {
    ///文字
    var chs: String?
    ///图片
    var png: String? {
        didSet {
            imagePath = EmoticonPackage.emoticonPath().appending("/\(id!)/\(png!)")
        }
    }
    ///表情全路径
    var imagePath: String?
    /// 标记是否是删除按扭
    var isRemoveBtn: Bool = false
    
    /// 记当当前表情使用次数
    var times: Int = 0
    
    /// 表情对应的16制字符串
    var code: String? {
        didSet {
            // 1.从字符串中取出 16 进制的数
            // 创建一个扫描器，扫描器可以从字符串中提取我们想要的数据
            let scanner = Scanner(string: code!)
            // 2.将 16 进制转换为字符串
            var result: UInt32 = 0
            scanner.scanHexInt32(&result)
            // 3.将 16 进制转换为 emoji 字符串
            emojiStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    ///emoji 字符串
    var emojiStr: String?
    ///表情组id 表情组文件夹
    var id: String?
    
    init(dict: [String: String], id: String) {
        super.init()
        self.id = id
        setValuesForKeys(dict)
    }
    
    /// 是否是回退按钮
    ///
    /// - Parameter isRemoveBtn: 是否是回退按钮
    init(isRemoveBtn: Bool) {
        super.init()
        self.isRemoveBtn = isRemoveBtn
    }
    
    /// 通过表情文字转换表情模型
    ///
    /// - Parameter str: 表情文字
    /// - Returns: 表情模型
    class func emoticonWithStr(str: String) -> Emoticon? {
        var emoticon: Emoticon?
        for package in EmoticonPackage.packagesList {
            emoticon = package.emoticons?.filter({ (e) -> Bool in
                return e.chs == str
            }).first
            if emoticon != nil {
                break
            }
        }
        return emoticon
    }
    
    /// 传入字符串，返回带表情的AttributedString
    ///
    /// - Parameters:
    ///   - str: 字符串
    ///   - font: 字体
    /// - Returns: 带表情的AttributedString
    class func emoticonAttributedStr(str: String, font: UIFont) -> NSAttributedString? {
        let strAttr = NSMutableAttributedString(string: str)
        do {
            // 1.创建规则
            let pattern = "\\[.*?\\]"
            // 2.创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            // 3.开始匹配
            let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                    range: NSRange(location: 0, length: str.characters.count))
            var count = res.count
            while count > 0 {
                // 0.从后往前取
                count = count - 1
                let checkingRes = res[count]
                // 1.拿到匹配到的表情字符串
                let tempStr = (str as NSString).substring(with: checkingRes.range)
                // 2.根据表情字符串查找对应的表情模型
                if let emoticon = Emoticon.emoticonWithStr(str: tempStr) {
                    // 3.根据表情模型生成属性字符串
                    let attrStr = EmoticonTextAttachment.imageText(emoticon: emoticon, fontSize: font.lineHeight)
                    // 4.添加属性字符串
                    strAttr.replaceCharacters(in: checkingRes.range, with: attrStr)
                }
            }
        } catch {
            print(error)
        }
        return strAttr
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
}
