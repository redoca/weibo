//
//  WHLabel.swift
//  Weibo
//
//  Created by 王焕 on 2016/11/11.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

class WHLabel: UILabel {
    
    override var text: String? {
        didSet {
            // 1.修改 textStorage 存储的内容
            textStorage.setAttributedString(NSAttributedString(string: text!))
            // 2.设置 textStorage 属性
            textStorage.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: text!.characters.count))
            
            // 3.处理 url
            self.urlRegex()
            // 2.通知 layoutManager 得新布局
            setNeedsDisplay()
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            // 1.修改 textStorage 存储的内容
            textStorage.setAttributedString(attributedText!)
            // 2.设置 textStorage 属性
            textStorage.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: attributedText!.string.characters.count))
            // 3.处理 url
            self.urlRegex()
            // 2.通知 layoutManager 得新布局
            setNeedsDisplay()
        }
    }
    
    // 如果是 UILabel 调用 setNeedsDisplay 方法，系统会促发 drawTextInRect
    override func drawText(in rect: CGRect) {
        // 重绘
        // 字形， 理解为一个小的 UIView
        layoutManager.drawGlyphs(forGlyphRange: NSRange(location: 0, length: (text?.characters.count)!), at: CGPoint.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSystem() {
        // 1.将 layoutManager 添加到 textStorage
        textStorage.addLayoutManager(layoutManager)
        // 2.将 textContainer 添加到 layoutManager
        layoutManager.addTextContainer(textContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size
    }
    
    func urlRegex() {
        // 1.创建一个正则表达式对象
        do {
            let dataDetector = try NSDataDetector(types: NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            let res = dataDetector.matches(in: textStorage.string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: textStorage.string.characters.count))
            for checkingRes in res {
                let str = (textStorage.string as NSString).substring(with: checkingRes.range)
                let tempStr = NSMutableAttributedString(string: str)
                tempStr.addAttributes([NSFontAttributeName: font,
                                       NSForegroundColorAttributeName : UIColor.blue],
                                      range: NSRange(location: 0, length: str.characters.count))
                textStorage.replaceCharacters(in: checkingRes.range, with: tempStr)
            }
        } catch {
            
        }
    }
    
    // MARK: - 懒加载
    // 准备用于存储内容的
    // textStorage 中有 layoutManager
    private lazy var textStorage = NSTextStorage()
    // 专门用于管理布局
    // layoutManager 中有 textContainer
    private lazy var layoutManager = NSLayoutManager()
    // 专门用于指定绘制的区域
    private lazy var textContainer = NSTextContainer()
    
}
