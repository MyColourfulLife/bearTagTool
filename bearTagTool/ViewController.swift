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
import MBProgressHUD



class ViewController: UIViewController {
    
    
    var session:            AVCaptureSession!               //session
    var videoInput:         AVCaptureDeviceInput!           //输入
    var stillImageOutput:   AVCaptureStillImageOutput!      //输出
    var layerPreview:       AVCaptureVideoPreviewLayer!     //预览层
    var device:             AVCaptureDevice!
    
    var controlView:        UIView!                         //容器视图
    
    static let uuid: String = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceInfo.uuid.rawValue)!
    
    static let uuidlast4carater = uuid[uuid.index(uuid.endIndex, offsetBy: -4)..<uuid.endIndex]
    let deviceType: String? = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceInfo.modelName.rawValue)
    
    let deviceName: String? = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceInfo.deviceName.rawValue)
    
    let tagSwitch = UISwitch()
    
    var hub: MBProgressHUD! = nil
    
    var smallSize: CGSize?
    
    
    var deviceScale = CGFloat(1.0)
    
    
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
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)

       
        //获取屏幕宽度
        let wid =  (UIScreen.main.bounds.width - 40)/3
        smallSize = CGSize(width: wid, height: wid)
        
        
        
    }
    
    
    
    /// 添加并配置控制视图
    func configContrlView() -> Void {
        
        let applicationframe = UIScreen.main.bounds.size
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
        let tag = UserDefaults.standard.integer(forKey: "tagSwitchStatus")
        hub = MBProgressHUD.showAdded(to: view, animated: true)
        hub.mode = .text
        hub.removeFromSuperViewOnHide = true
        if (tag == 0) {
            tagSwitch.isOn = true
            UserDefaults.standard.set(1, forKey: "tagSwitchStatus")
            hub.label.text = "当前状态处于手动标注状态"
            hub.hide(animated: true, afterDelay: 3)
        } else if (tag == 1){
            tagSwitch.isOn = true
            hub.label.text = "当前状态处于手动标注状态"
            hub.hide(animated: true, afterDelay: 3)
        } else {
            tagSwitch.isOn = false
            hub.label.text = "当前状态处于非手动标注状态"
            hub.hide(animated: true, afterDelay: 3)
        }
       
        
        tagSwitch.addTarget(self, action: #selector(tagSwitchChange(sender:)), for: .valueChanged)
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
        albumEntryBtn.addTarget(self, action: #selector(scanImage), for: .touchUpInside)

        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomView(sender:)))
        controlView.addGestureRecognizer(zoomGesture)
        
        
    }
    
    
    
    @objc func zoomView(sender:UIPinchGestureRecognizer) {
        
        var scale = deviceScale + (sender.scale - 1 );
        
        //最大5倍 最小1倍
        if scale > 5 {
            scale = 5
        } else if (scale < 1){
            scale = 1
        }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = scale
            device.unlockForConfiguration()
        } catch _ {
            
        }
        
        
        if sender.state == .ended {
            deviceScale = scale
        }
        
        
        
    }
    
    
    
    
    @objc func tagSwitchChange(sender: UISwitch) {
        
        if sender.isOn == false {
            UserDefaults.standard.set(3, forKey: "tagSwitchStatus")
        } else {
             UserDefaults.standard.set(1, forKey: "tagSwitchStatus")
        }
        
        
    }

    
    
    func initAVCaputerSeesion() {
        
        
        do{
            //            1.创建会话 输入 和 输出
            self.session = AVCaptureSession()
            
            device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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
            
            errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: { [unowned self] (UIAlertAction) in
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
    
    
    
    @objc func scanImage() {
        
        let collectionLayout = UICollectionViewFlowLayout()
        
        let space: CGFloat = 5
        
        let imgSize = (view.frame.width - 4 * space - 4 * space) / 3
        
        collectionLayout.itemSize = CGSize(width: imgSize, height: imgSize)
        collectionLayout.minimumInteritemSpacing = space
        collectionLayout.minimumLineSpacing = space * 2
        collectionLayout.sectionInset = UIEdgeInsets(top: 2*space, left: 2*space, bottom: 0, right: 2*space)
        
        let scanViewCtr = ImageScanViewController(collectionViewLayout: collectionLayout)
        navigationController?.pushViewController(scanViewCtr, animated: true)
        
        
    }
    
    
    
    @objc func takePhoto() {
        
//        self.shutterAnimation()
        
        let stillimageConnect: AVCaptureConnection = self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo)!
        
        let curDeviceOrientation = UIDevice.current.orientation
        
        let avcaptureOrientation = self.avOrientationForDeciceOrientation(deviceOrientation: curDeviceOrientation)
        
        stillimageConnect.videoOrientation = avcaptureOrientation
        stillimageConnect.videoScaleAndCropFactor = 1.0
        
        stillImageOutput.captureStillImageAsynchronously(from: stillimageConnect) { (imgaeDataSampleBuffer, error) in
            
            if error != nil {
                return;
            }
            
            let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imgaeDataSampleBuffer!)
            
            if let image = UIImage(data: jpegData!) {
                
                var image = image
                
                image = fixOrientation(image: image)
               
                let size = image.size
//                保存到系统相册
//                saveToAlbum(image: image)
                
//               压缩图片
              let compressData = UIImageJPEGRepresentation(image, 0.5)
//                写入沙盒
//                设置图片名称 IDBEAR_20170812_0987_00001.jpeg
                
                //保存文件到沙盒
                let (fileName,timeStamp) = createImgName()
                
                //保存原图到沙盒
                let filePath = PhotoManager.defaultManager.createFilePath(fileName: fileName)
                PhotoManager.defaultManager.createFile(at: filePath, contents: compressData!)
                
                //保存缩略图到沙盒
                
                //创建缩略图
                
               let smallImage = image.scaleTo(size: self.smallSize!)
                
                //命名 源文件加前追 compress_
               let smallImageName = "compress_" + fileName
                
                //保存缩略图到沙盒
                let smallfilePath = PhotoManager.defaultManager.createFilePath(fileName: smallImageName)
                let smallData = UIImageJPEGRepresentation(smallImage, 0.5)!
                PhotoManager.defaultManager.createFile(at: smallfilePath, contents: smallData)
                
                
                //保存到数据库
                let photoItem = PhotoItem()
                photoItem.deviceType = self.deviceType ?? DeviceInfoManager.deviceType!
                photoItem.deviceName = self.deviceName ?? DeviceInfoManager.phoneName!
                photoItem.fileName = fileName
                photoItem.fileSize = (compressData?.count)!
                photoItem.fileWidth = Double(size.width)
                photoItem.fileHeight = Double(size.height)
                photoItem.createDate = timeStamp
                photoItem.filePath =  filePath
                photoItem.smallImgName = smallImageName
                photoItem.smallImgPath = smallfilePath
                
                RealmManager.realmManager.doWriteHandler {
                    RealmManager.realmManager.realm.add(photoItem)
                }
                
                if self.tagSwitch.isOn == true {
                    
                    //如果开启了标注就弹出标注页面
                    let markViewCtr = MarkViewController(imagePath:filePath,comperssImgPath:smallfilePath)
                    markViewCtr.imgName = fileName
                    self.navigationController?.present(markViewCtr, animated: true, completion: nil)

                }
                
                
            }
    }
    
        
        // 修复图片旋转
        func fixOrientation(image:UIImage) -> UIImage {
            
            if image.imageOrientation == .up {
                return image
            }
            
            var transform = CGAffineTransform.identity
            
            switch image.imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: image.size.height)
                transform = transform.rotated(by: .pi)
                break
                
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0)
                transform = transform.rotated(by: .pi / 2)
                break
                
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: image.size.height)
                transform = transform.rotated(by: -.pi / 2)
                break
                
            default:
                break
            }
            
            switch image.imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
                break
                
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: image.size.height, y: 0);
                transform = transform.scaledBy(x: -1, y: 1)
                break
                
            default:
                break
            }
            
            let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
            ctx?.concatenate(transform)
            
            switch image.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx?.draw(image.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.height), height: CGFloat(image.size.width)))
                break
                
            default:
                ctx?.draw(image.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height)))
                break
            }
            
            let cgimg: CGImage = (ctx?.makeImage())!
            let img = UIImage(cgImage: cgimg)
            
            return img
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
        func createImgName()->(String,Int) {
            
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
            
//            print("时间戳\(timeStamp)，拍照时间：\(nowFormatString)")
            
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
            
            
//            print("图片名称：\(imgName)")
            
            return (imgName, timeStamp)
        }
        
        
     
        /// 保存到系统相册
        ///
        /// - Parameter image: 图片
        func saveToAlbum(image: UIImage) {
            
            if PhotoManager.defaultManager.assetCollection == nil {
                PhotoManager.defaultManager.createAlbum(authorError: {[unowned self] error in
                    
                    let errorAlert = UIAlertController(title: "保存相片失败", message: "请在iPhone的\"设置-隐私-照片\"选项中，允许本程序访问您的照片", preferredStyle: .alert)
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: {[unowned self] (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                })
            } else {
                
                PhotoManager.defaultManager.savePhoto(image: image, authorError: {
                  [unowned self]  error in
                    
                    let errorAlert = UIAlertController(title: "保存相片失败", message: "请在iPhone的\"设置-隐私-照片\"选项中，允许本程序访问您的照片", preferredStyle: .alert)
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    errorAlert.addAction(UIAlertAction(title: "好的", style: .default, handler: {[unowned self] (UIAlertAction) in
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
        deviceScale = 1.0
        if device != nil {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = deviceScale
                device.unlockForConfiguration()
            } catch _ {
                
            }
        }
        self.session.startRunning()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }
    


    
    
   
    
}

extension UIImage {
    
    /// 缩放到指定大小
    /// 
    ///
    /// - Parameter size: 缩放的尺寸
    /// - Returns: 缩放后的图片
    func scaleTo(size:CGSize) -> UIImage {
    
//        开启画布
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        UIGraphicsGetCurrentContext()!.interpolationQuality = .default
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let zoomImage = UIGraphicsGetImageFromCurrentImageContext()
            
        UIGraphicsEndImageContext()
        
        return zoomImage!
    }
    
}




