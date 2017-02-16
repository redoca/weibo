//
//  UITextView+Category.swift
//  😀😬😁
//
//  Created by 王焕 on 2016/10/10.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

extension UITextView {
    
    /// 写入表情
    ///
    /// - parameter emoticon: 表情对象
    func insertEmoticon(emoticon: Emoticon) {
        // 0.处理删除按钮
        if emoticon.isRemoveBtn {
            deleteBackward()
        }
        // 1.emoji表情
        if emoticon.emojiStr != nil {
            self.replace(self.selectedTextRange!, withText: emoticon.emojiStr!)
        }
        // 2.表情图片
        if emoticon.png != nil {
            // 1.创建图片附件
            // 2.创建属性字符串
            let imageText = EmoticonTextAttachment.imageText(emoticon: emoticon, fontSize: font!.lineHeight)
            // 3.拿到当前所有内容
            let strM = NSMutableAttributedString(attributedString: self.attributedText)
            // 4.插入表情到当前光标所在位置
            let range = self.selectedRange
            strM.replaceCharacters(in: range, with: imageText)
            // 属性字符串有自己默认的尺寸，需要设置
            strM.addAttribute(NSFontAttributeName, value: font!, range: NSRange.init(location: range.location, length: 1))
            // 5.将替换后的字符串赋值给 textView
            self.attributedText = strM
            // 6.恢复光标所在的位置
            self.selectedRange = NSMakeRange(range.location + 1, 0)
            // 7.自己主动触发 textViewDidChange方法
            delegate?.textViewDidChange!(self)
        }
    }
    
    /// 发送文本
    ///
    /// - returns: 返回发送文本
    func emoticonText() -> String {
        var strM = String()
        self.attributedText.enumerateAttributes(in: NSRange(location: 0, length: self.attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (obj, range, _) in
            //            print(obj)
            //            print(range)
            //            let res = (self.textView.text as NSString).substring(with: range)
            //            print(res)
            if obj["NSAttachment"] != nil {
                let attachment = obj["NSAttachment"] as! EmoticonTextAttachment
                strM += attachment.chs!
            } else {
                strM += (self.text as NSString).substring(with: range)
            }
        }
        return strM
    }
}
