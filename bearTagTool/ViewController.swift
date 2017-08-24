//
//  ViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/22.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation



class ViewController: UIViewController {
    
    
    var session:            AVCaptureSession!               //session
    var videoInput:         AVCaptureDeviceInput!           //输入
    var stillImageOutput:   AVCaptureStillImageOutput!      //输出
    var layerPreview:       AVCaptureVideoPreviewLayer!     //预览层
    
    var controlView:        UIView!                         //容器视图
    
    static let uuid: String = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceInfo.uuid.rawValue)!
    static let uuidlast4carater = uuid.substring(from: uuid.index(uuid.endIndex, offsetBy: -4))

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        添加控制视图
        configContrlView()
        
        
        //        初始化相机会话
        initAVCaputerSeesion()
        
        
        //        尝试创建相册
        
//        PhotoManager.defaultManager.createAlbum(authorError: { error in
//            
//                        let errorAlert = UIAlertController(title: "创建相册失败", message: "请在iPhone的\"设置-隐私-照片\"选项中，允许本程序访问您的照片", preferredStyle: .alert)
//                        self.present(errorAlert, animated: true, completion: nil)
//            
//                        errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (UIAlertAction) in
//                            self.dismiss(animated: true, completion: nil)
//                        }))
//            
//        })
        
        
        
       
        
    }
    
    
    
    /// 添加并配置控制视图
    func configContrlView() -> Void {
        
        let applicationframe = UIScreen.main.applicationFrame.size
        self.controlView = UIView(frame: CGRect(x: 0, y: 64, width: applicationframe.width, height: applicationframe.height - 44))
        controlView.backgroundColor = UIColor.clear
        self.view.addSubview(controlView)
        
        
        //      图片存放位置
        
        let albumEntryBtn = UIButton(type: .custom)
        controlView.addSubview(albumEntryBtn)
        
        albumEntryBtn.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(10)
        }
        
        albumEntryBtn.setImage(#imageLiteral(resourceName: "imgEntry"), for: .normal)
        
        
        //      手动开关
        let tagSwitch = UISwitch()
        tagSwitch.isOn = true
        controlView.addSubview(tagSwitch)
        
        tagSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(albumEntryBtn)
        }
        
        
        //      拍照按钮
        let takePhotoBtn = UIButton(type: .custom)
        controlView.addSubview(takePhotoBtn)
        takePhotoBtn.setImage(#imageLiteral(resourceName: "carama"), for: .normal)
        
        takePhotoBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-20)
            make.centerX.equalTo(view)
            make.width.height.equalTo(50)
        }
        
        
        //        事件处理
        takePhotoBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        
    }
    
    
    func initAVCaputerSeesion() {
        
        
        do{
            //            1.创建会话 输入 和 输出
            self.session = AVCaptureSession()
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            self.videoInput = try AVCaptureDeviceInput(device: device)
            self.stillImageOutput = AVCaptureStillImageOutput()
            let outPutsetting = [AVVideoCodecKey: AVVideoCodecJPEG]
            stillImageOutput.outputSettings = outPutsetting
            
            //            2.会话中添加输入和输出
            self.session.addInput(self.videoInput)
            self.session.addOutput(self.stillImageOutput)
            
            //            3.初始化预览层
            self.layerPreview = AVCaptureVideoPreviewLayer(session: self.session)
            self.layerPreview.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.layerPreview.frame = self.controlView.frame
            self.view.layer.insertSublayer(self.layerPreview, at: 0)
            
            //            4.运行会话
            self.session.startRunning()
            
            
        }catch _ as NSError{
            
            //打印错误消息
            
            let errorAlert = UIAlertController(title: "提醒", message: "请在iPhone的\"设置-隐私-相机\"选项中，允许本程序访问您的相机", preferredStyle: .alert)
            self.present(errorAlert, animated: true, completion: nil)
            
            errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            
        }
        
    }
    
    
    /// 根据手机的方向调整拍出来的图片方向
    ///
    /// - Parameter deviceOrientation: 设备方向
    /// - Returns: 图片方向
    func avOrientationForDeciceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        
        var result = AVCaptureVideoOrientation.portrait
        
        if deviceOrientation == UIDeviceOrientation.landscapeLeft {
            result = AVCaptureVideoOrientation.landscapeRight
        } else if deviceOrientation == UIDeviceOrientation.landscapeRight {
            
            result = AVCaptureVideoOrientation.landscapeLeft
            
        }
        
        return result
        
        
    }
    
    
    
    
    func takePhoto() {
        
        self.shutterAnimation()
        
        let stillimageConnect: AVCaptureConnection = self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
        
        let curDeviceOrientation = UIDevice.current.orientation
        
        let avcaptureOrientation = self.avOrientationForDeciceOrientation(deviceOrientation: curDeviceOrientation)
        
        stillimageConnect.videoOrientation = avcaptureOrientation
        stillimageConnect.videoScaleAndCropFactor = 1.0
        
        stillImageOutput.captureStillImageAsynchronously(from: stillimageConnect) { (imgaeDataSampleBuffer, error) in
            
            
            let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imgaeDataSampleBuffer)
            
            
            
            if let image = UIImage(data: jpegData!) {
               
//                保存到系统相册
//                saveToAlbum(image: image)
                
//               压缩图片
              let compressData = UIImageJPEGRepresentation(image, 0.6)
//                写入沙盒
//                设置图片名称 IDBEAR_20170812_0987_00001.jpeg
                
                //保存文件到沙盒
                PhotoManager.defaultManager.createFile(at: PhotoManager.defaultManager.createFilePath(fileName: createImgName()), contents: compressData!)
                
            }
    }
    
        
        /// 获取图片名列表
        ///
        /// - Returns: 数组，如无为空
        func getImageNamesList()->Array<String>{
            let imglist = PhotoManager.defaultManager.getImgList(path: PhotoManager.defaultManager.createImageSandBoxPath())
            
            return imglist ?? []
        }
        
        
        /// 创建图片名称
        ///  IDBEAR_20170812_0987_00001.jpeg
        /// - Returns: 图片名称
        func createImgName()->String {
            
            var imgName: String = ""
            
            //1. 获取当前时间
            let now = Date()
            //2.创建时间格式
            let dateFormatter =  DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            //2. 获取格式化后的字符串
            let nowFormatString = dateFormatter.string(from: now)
            
            //时间戳
            let timeStamp = Int(now.timeIntervalSince1970)
            
            print("时间戳\(timeStamp)，拍照时间：\(nowFormatString)")
            
            //3. uuid后四位 uuidlast4carater
            
            
            //4. 当前是第几张照片
            // 读取数字
            var imgIndex: Int = UserDefaults.standard.integer(forKey: "imgIndex")
            imgIndex = imgIndex + 1
            //同步到本地
            UserDefaults.standard.set(imgIndex, forKey: "imgIndex")
            
            let imgIndexStr = String.init(format: "%05d", imgIndex)
            
            //5. 拼接图片名称
            imgName = "IDBEAR_\(nowFormatString)_\(ViewController.uuidlast4carater)_\(imgIndexStr).jpeg"
            
            
            print("图片名称：\(imgName)")
            

            return imgName
        }
        
        
     
        /// 保存到系统相册
        ///
        /// - Parameter image: 图片
        func saveToAlbum(image: UIImage) {
            
            if PhotoManager.defaultManager.assetCollection == nil {
                PhotoManager.defaultManager.createAlbum(authorError: { error in
                    
                    let errorAlert = UIAlertController(title: "保存相片失败", message: "请在iPhone的\"设置-隐私-照片\"选项中，允许本程序访问您的照片", preferredStyle: .alert)
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                })
            } else {
                
                PhotoManager.defaultManager.savePhoto(image: image, authorError: {
                    error in
                    
                    let errorAlert = UIAlertController(title: "保存相片失败", message: "请在iPhone的\"设置-隐私-照片\"选项中，允许本程序访问您的照片", preferredStyle: .alert)
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    
                })
                
            }
            
        }
        

        
    }
    

    
    
    func shutterAnimation() {
//        self.controlView.layer.removeAnimation(forKey: "cameraIris")
//        let shuteranimation: CATransition = CATransition()
//        shuteranimation.duration = 0.5
//        shuteranimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
//        shuteranimation.type = "cameraIris"
//        shuteranimation.subtype = "cameraIris"
//        self.layerPreview.add(shuteranimation, forKey: "cameraIris")
        
        
        UIView.animate(withDuration: 0.1, animations: {
             self.controlView.backgroundColor = UIColor.black
        }) { (done) in
             self.controlView.backgroundColor = UIColor.clear
        }
        
        
    }
    
//    cameraIris
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.session.startRunning()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.session.stopRunning()
    }
    
}






