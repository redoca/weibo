//
//  ComposeViewController.swift
//  Weibo
//
//  Created by 王焕 on 16/8/30.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {
    
    /// 工具条底部约束，用于在弹出键盘时变更工具条位置
    var toolBarBottonCons: NSLayoutConstraint?
    /// 图片选择器高度约束
    var photoViewHeightCons: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
    
        // 0.注册通知监听键盘弹出和消失的Frame
        NotificationCenter.default.addObserver(self, selector:#selector(ComposeViewController.keyBoardChange(notify:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        // 0.注册通知监听键盘弹出
        NotificationCenter.default.addObserver(self, selector:#selector(ComposeViewController.keyboardWillShow(notify:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // 将键盘控制器添加为当前控制器的子控制器
        addChildViewController(emoticonVC)
        addChildViewController(photoSelectorVC)
        // 1.初始化导航条
        setupNav()
        // 2.初始化界面
        setupUI()
        // 3.初始化图片选择器
        setupPhotoView()
        // 4.初始化工具条
        setupToolBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 只要键盘改变就会调用
    ///
    /// - Parameter notify: 通知
    func keyBoardChange(notify: Notification) {
        print(notify)
        // 1.取出键盘最终的rect
        let value = notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let rect = value.cgRectValue
        // 2.修改工具条的约束
        toolBarBottonCons?.constant = -(UIScreen.main.bounds.height - rect.origin.y)
        // 3.更新界面
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        // 取出键盘的动画节奏
        let curve = notify.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        UIView.animate(withDuration: duration.doubleValue) {
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.intValue)!)
            self.view.layoutIfNeeded()
        }
//        view.layoutIfNeeded()
    }
    
    /// 键盘将出通知
    ///
    /// - Parameter notify: 通知
    func keyboardWillShow(notify: Notification) {
        print(notify)
        photoViewHeightCons?.constant = 0
        UIView.animate(withDuration: 0.25) {
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if photoViewHeightCons?.constant == 0 {
            // 主动召唤键盘
            textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 主动消失键盘
        textView.resignFirstResponder()
    }
    
    /**
     初始化导航条
    */
    private func setupNav() {
        // 1.添加左边按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem (title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ComposeViewController.close))
        // 2.添加右边按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem (title: "发送", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ComposeViewController.sendStatus))
        navigationItem.rightBarButtonItem?.isEnabled = false
        // 3.添加中间视图
        navigationItem.titleView = titleView
    }
    
    /**
     初始化界面
     */
    private func setupUI() {
        // 1.添加子控件
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        // 2.布局子控件
        textView.xmg_Fill(textView)
        placeholderLabel.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 8))
    }
    
    /// 底部工具条
    private func setupToolBar() {
        // 1.添加子控件
        view.addSubview(toolBar)
        view.addSubview(tipLabel)
        
        // 2布局toolbar
        let width = UIScreen.main.bounds.width
        let cons = toolBar.xmg_AlignInner(type: XMG_AlignType.bottomLeft, referView: view, size: CGSize(width: width, height: 44))
        toolBarBottonCons = toolBar.xmg_Constraint(cons, attribute: NSLayoutAttribute.bottom)
        tipLabel.xmg_AlignVertical(type: XMG_AlignType.topRight, referView: toolBar, size: nil, offset: CGPoint.init(x: -10, y: -10))
    }
    
    /// 始初化图片选择器
    private func setupPhotoView() {
        // 1.添加图片选择器
        view.insertSubview(photoSelectorVC.view, belowSubview: toolBar)
        // 2.布局图片选择器
        let size = UIScreen.main.bounds.size
        let width = size.width
        let height: CGFloat = 0
        let cons = photoSelectorVC.view.xmg_AlignInner(type: XMG_AlignType.bottomLeft, referView: view, size: CGSize.init(width: width, height: height))
        photoViewHeightCons = photoSelectorVC.view.xmg_Constraint(cons, attribute: NSLayoutAttribute.height)
    }
    
    /// 选择相片
    func selectPicture() {
        // 1.关闭键盘
        textView.resignFirstResponder()
        // 2.调整图片选择器的高度
        photoViewHeightCons?.constant = UIScreen.main.bounds.height * 0.5
        UIView.animate(withDuration: 0.25) {
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            self.view.layoutIfNeeded()
        }
    }
    
    /// 切换表情键盘
    func inputEmoticon() {
        // 如果是系统键盘，那么inputView = nil
        // 如果不是系统自带的键盘，那么 inputView != nil
        
        // 1.关闭键盘
        textView.resignFirstResponder()
        // 2.设置 inputView
        textView.inputView = textView.inputView == nil ? emoticonVC.view : nil
        // 3.从新如唤出键盘
        textView.becomeFirstResponder()
    }
    
    /**
     关闭控制器
    */
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     发送微博
     */
    func sendStatus() {
        let image = photoSelectorVC.pictureImages.first
        NetworkTools.shareNetworkTools().sendStatus(text: textView.emoticonText(), image: image,
        successCallback: { (status) in
            SVProgressHUD.showSuccess(withStatus: "微博发送成功")
            self.close()
        }, failCallback: { (error) in
            print(error)
            SVProgressHUD.showError(withStatus: "微博发送失败")
        }) { (progress) in
            SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "发送中")
        }
    }
    
    // MARK: - 懒加载
    // nav 中间title
    private lazy var titleView : UIView = {
        let titleView = UIView(frame: CGRect (x: 0, y: 0, width: 100, height: 32))
        
        let label1 = UILabel()
        label1.text = "发送微博"
        label1.font = UIFont.systemFont(ofSize: 14)
        label1.sizeToFit()
        titleView.addSubview(label1)
        
        let label2 = UILabel()
        label2.text = UserAccount.loadAccount()?.screen_name
        label2.font = UIFont.systemFont(ofSize: 12)
        label2.textColor = UIColor.darkGray
        label2.sizeToFit()
        titleView.addSubview(label2)
        
        label1.xmg_AlignInner(type: XMG_AlignType.topCenter, referView: titleView, size: nil)
        label2.xmg_AlignInner(type: XMG_AlignType.bottomCenter, referView: titleView, size: nil)
        
        return titleView
    }()
    // 微博输入框
    private lazy var textView : UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.alwaysBounceVertical = true //永远可以拖拽
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag //键盘隐藏模式
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    // 微博输入框提示
    fileprivate lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.text = "分享新鲜事..."
        return label
    }()
    /// 底部工具条
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        var items = [UIBarButtonItem]()
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoticon"],
                            ["imageName": "compose_addbutton_background"]]
        for dict in itemSettings {
            let item = UIBarButtonItem(imageName: dict["imageName"]!, target: self, action: dict["action"])
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolBar.items = items
        return toolBar
    }()
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        return label
    }()
    /// 表情
    // ⚠️注意循环♻️引用⚠️
    // weak 相当于 OC 中的 __weak, 特点对象释放之后会将变量设置为 nil
    // unowned 相当于 OC 中的 unsafe_unretained, 特点对象释放之后不会将变量设置为 nil
    private lazy var emoticonVC: EmoticonViewController =
        EmoticonViewController.init { [unowned self] (emoticon) in
            self.textView.insertEmoticon(emoticon: emoticon)
    }
    /// 图片选择器
    private lazy var photoSelectorVC: PhotoSelectorViewController = {
        let vc = PhotoSelectorViewController()
        return vc
    }()
}

private let maxTipLength = 140  // 长度限制
extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 1.隐藏 placeholder
        placeholderLabel.isHidden = textView.hasText
        // 2.控制发送按钮
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
        // 3.显示文字限制
        let count = textView.emoticonText().characters.count
        tipLabel.text = "\(count) / \(maxTipLength)"
        tipLabel.text = (count == 0) ? "" : tipLabel.text
        navigationItem.rightBarButtonItem?.isEnabled = count <= maxTipLength

    }
}
