//
//  EmoticonTextAttachment.swift
//  😀😬😁
//
//  Created by 王焕 on 2016/10/10.
//  Copyright © 2016年 王焕. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {

    // 保存对应表情的文字
    var chs: String?
    
    // 根据表情模型创建表情字符串
    class func imageText(emoticon: Emoticon, fontSize: CGFloat) -> NSAttributedString{
        // 1.创建图片附件
        let attachment = EmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        attachment.bounds = CGRect(x: 0, y: -4, width: fontSize, height: fontSize)
        
        return NSAttributedString(attachment: attachment)
    }
}
