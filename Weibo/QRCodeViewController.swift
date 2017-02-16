//
//  QRCodeViewController.swift
//  Weibo
//  二维码扫描
//  Created by 王焕 on 16/5/28.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import AVFoundation

import CoreGraphics

class QRCodeViewController: UIViewController, UITabBarDelegate {

    var QRHightCon = NSLayoutConstraint() // QRView 高
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置 Nav
        setupNav()
        
        // 设置子控件
        view.addSubview(qrView)
        view.addSubview(qrTabBar)
        view.addSubview(cardBtn)
        
        // 布局
        setQRViewConstraint()
        qrTabBar.xmg_AlignVertical(type: XMG_AlignType.bottomCenter, referView: view,
                                   size: CGSize(width: UIScreen.main.bounds.width, height: 49),
                                   offset: CGPoint(x: 0, y: -49))
        cardBtn.xmg_AlignVertical(type: XMG_AlignType.bottomCenter, referView: qrView, size: nil,
                                  offset: CGPoint(x: 0, y: 20))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    
    /**
     开始扫描
     */
    func startScan() {
        // 1. 判断是否能够将输入添加到会话中
        if !session.canAddInput(deviceInput) {
            return
        }
        // 2. 判断是否能够将输出添加到会话中
        if !session.canAddOutput(output) {
            return
        }
        // 3. 将输入和输出都添加到会话中
        session.addInput(deviceInput)
        session.addOutput(output)
        // 4. 设置输出能够解析的数据类型
        // 在添加输出对象会话之后天加数据类型
        output.metadataObjectTypes = output.availableMetadataObjectTypes //所有类型
        // 5. 设置输入对象的代理，只要解析成功就会通知代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 如果想实现只扫描一张图片，那么系统自代的二维码扫描是不支持的
        // 只能设置让二维码只有出现在某一块区域才去扫描
//        output.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        // 添加预览图层
        view.layer.insertSublayer(previewLayer, at: 0)
        //  添加绘制图层到预览图层
        previewLayer.addSublayer(drawLayer)
        // 6. 告诉 session 开始扫描
        session.startRunning()
    }
    
    /**
     布局 QRView
     */
    func setQRViewConstraint() {
        qrView.translatesAutoresizingMaskIntoConstraints = false
        let  widthCon =
            NSLayoutConstraint(item: qrView,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 200)
        QRHightCon =
            NSLayoutConstraint(item: qrView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 200)
        let  xCon =
            NSLayoutConstraint(item: qrView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1.0,
                               constant: 0)
        let  yCon =
            NSLayoutConstraint(item: qrView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerY,
                               multiplier: 1.0,
                               constant: 0)
        view.addConstraints([widthCon, QRHightCon, xCon, yCon])
    }

    /**
     设置 Nav
     */
    private func setupNav() {
        // 1.左边按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftItemClick))
        // 2.右边按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "相册", style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightItemClick))
        // 3.nav颜色
        navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func leftItemClick() {
        dismiss(animated: true, completion: nil)
    }
    
    func rightItemClick() {
        
    }
    
    /**
     我的名片
     */
    func cardBtnClick() {
        let vc = QRCodeCardViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            QRHightCon.constant = 200  /// 二维码
        } else {
            QRHightCon.constant = 100  /// 条形码
        }
//        qrView.scanlineImgView.layer.removeAllAnimations()
    }
    
    //MARK: - 懒加载
    
    /// QR扫描区View
    private lazy var qrView: QRView = QRView()
    
    /// TabBar
    private lazy var qrTabBar: QRTabBar = {
        let qrTabBar = QRTabBar()
        qrTabBar.delegate = self
        return qrTabBar
    }()
    
    // 会话
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    // 拿到输入设备
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        // 获取摄像头
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        } catch {
            print(error)
            return nil
        }
    }()
    
    // 输出对象
    private lazy var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    // 创建预览图层
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer?.frame = UIScreen.main.bounds
        return layer!
    }()
    
    // 创建用于绘制边线的图层
    fileprivate lazy var drawLayer: CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.main.bounds
        return layer
    }()
    
    //我的名片按钮
    private lazy var cardBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn .setTitle("我的名片", for: UIControlState())
        btn.addTarget(self, action: #selector(QRCodeViewController.cardBtnClick),
                      for: UIControlEvents.touchUpInside)
        return btn
    }()
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // 清空图层
        clearConers()
        
        // 1. 获取扫描到的数据
        // 注意: 要使用stringValue
//        resultLabel.text = metadataObjects.last?.stringValue
//        resultLabel.sizeToFit()
        print((metadataObjects.last as? AVMetadataMachineReadableCodeObject)?.stringValue ?? "")
        
        // 2. 获取扫描到的位置
        // 2.1 转换坐标
        for object in metadataObjects {
            // 2.1.1 判断当前获取到的数据，是否是机器机可识别的类型
            if object is AVMetadataMachineReadableCodeObject {
                // 2.1.2 奖坐标转换为可识别坐标
                let codeObject = previewLayer.transformedMetadataObject(for: object as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
                drawCorners(codeObject)
            }
        }

    }
    
    /**
     绘制图形
     
     - parameter codeObject: 保存了坐标的对象
     */
    private func drawCorners(_ codeObject: AVMetadataMachineReadableCodeObject) {
        if codeObject.corners.isEmpty {
            return
        }
        // 1. 创建一个图层
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.clear.cgColor
        // 2. 创建路径
//        layer.path = UIBezierPath(rect: CGRect(x: 100, y:100, width: 200, height: 200)).CGPath
        let path = UIBezierPath()
        
        // FIXME: - 适配 swift 3
        
//        var index: Int = 0
//        let pointCFDic = codeObject.corners[index] as! CFDictionary
//        var point = CGPoint.init(dictionaryRepresentation: pointCFDic)
////        CGPointMakeWithDictionaryRepresentation((codeObject.corners[index] as! CFDictionary), &point)
//
//        // 2.1 移动到第一个点
////        point.makeWithdictionaryRepresentation((codeObject.corners[index] as! CFDictionary))
//        index += 1
//        path.move(to: point!)
//        // 2.2 移动到其它点
//        while index < codeObject.corners.count {
////            point.makeWithdictionaryRepresentation((codeObject.corners[index] as! CFDictionary))
//            index += 1
//            path.addLine(to: point!)
//        }
 
        // 2.3 关闭路径
        path.close()
        
        // 2.4 绘制路径
        layer.path = path.cgPath
        
        // 3. 将绘制好的图层添加到 drawLayer 上
        drawLayer.addSublayer(layer)
    }
    
    /**
     清空边线
     */
    private func clearConers() {
        // 1. 判断 drawLayer 上是否有其它图层
        if drawLayer.sublayers == nil || drawLayer.sublayers?.count == 0 {
            return
        }
        
        // 2. 移绘所有子图层
        for subLayer in drawLayer.sublayers! {
            subLayer.removeFromSuperlayer()
        }
    }
}
