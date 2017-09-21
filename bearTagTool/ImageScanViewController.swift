//
//  ImageScanViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD
import Alamofire

private let reuseIdentifier = "Cell"
//let uploadUrl = "http://192.168.1.170:8080/api/upload"
let uploadUrl = "http://www.id-bear.com/photoserver/api/upload";

class ImageScanViewController: UICollectionViewController {
    
    var smallSoucre:Array<String> = []
    var bigSoucre:Array<String> = []
    
    var imgIndex:Int!
    
    var editItem:UIBarButtonItem!

    var sortItem:UIBarButtonItem!
    
    var locateCellBtn:UIBarButtonItem!
    
    var uuidString:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefalut = UserDefaults.standard
       uuidString = userDefalut.string(forKey: UserDefaultKeys.DeviceInfo.uuid.rawValue)
        let dataSource:Array<String> = PhotoManager.defaultManager.getImgList(path: PhotoManager.defaultManager.createImageSandBoxPath())!
        
        //筛选出所有的缩略图和大图
        for name in dataSource {
            if name.hasPrefix("compress_") {
                smallSoucre.append(name)
            }else{
                bigSoucre.append(name)
            }
        }
        
        smallSoucre.sort(by: >)
        bigSoucre.sort(by: >)
        
        // Register cell classes
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.white
        title = "图片采集库"
        
        let sharetem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareClick))
        editItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action:  #selector(editClick))
        editItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.gray], for: .disabled)
        
        sortItem = UIBarButtonItem(title: "正序", style: .plain, target: self, action:  #selector(sortClick))
        sortItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.gray], for: .disabled)
        
       locateCellBtn = UIBarButtonItem(title: "定位", style: .plain, target: self, action:  #selector(locateCell))
        
        navigationItem.rightBarButtonItems = [sharetem,editItem,sortItem,locateCellBtn]
        
        
        editItem.isEnabled = smallSoucre.count != 0
    }
    
    
    
    
    
    /// 点击上传
    @objc func shareClick() {
    
            let databaseToShare = RealmManager.realmManager.realm.configuration.fileURL!
            var items = [databaseToShare]
            //imgToShare
        
            if self.bigSoucre.count > 0 {
                var count = 1
                let maxcount = self.bigSoucre.count
                let hub = MBProgressHUD.showAdded(to: self.view, animated: true)
                hub.mode = .determinateHorizontalBar
                hub.label.text = "共\(self.bigSoucre.count)张，正在上传第\(count)张"
                
                for imgName in self.bigSoucre {
                    let imgPath = PhotoManager.defaultManager.createFilePath(fileName: imgName)
                    let fileUrl = URL(fileURLWithPath: imgPath)
                    items.append(fileUrl)
                    
//                    1. 从数据库查找记录
                    let fiter: NSPredicate = NSPredicate(format: "fileName == %@", imgName)
                    if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
                        
                        //2. 准备所需参数
                        let fileInfo = NSMutableDictionary()
                        fileInfo["fileName"] = item.fileName
                        fileInfo["fileUrl"] = fileUrl
                        fileInfo["deviceType"] = item.deviceType
                        fileInfo["deviceName"] = item.deviceName
                        fileInfo["fileSize"] = ["width":item.fileWidth,"height":item.fileHeight]
                        fileInfo["createTime"] = String(item.createDate)
                        fileInfo["uuid"] = uuidString
                        if let frame = item.frame {
                             fileInfo["markFrame"] = ["x":frame.x,"y":frame.y,"width":frame.width,"height":frame.height]
                        } else {
                            fileInfo["markFrame"] = [:]
                        }
                       
//                        3. 上传文件
                        uploadFile(fileInfo: fileInfo, success: { (upload) in
                        
                            
                            upload.uploadProgress(closure: { (Progress) in
   
                            }).responseJSON(completionHandler: { (response) in

                                if let json = response.result.value {
                                    
                                let data = json as! NSDictionary
                                    
                                let code = data["code"]! as! Int
                                   
                                    if code == 1 {
                                        hub.progress = Float(count)/Float(maxcount)
                                        hub.label.text = "共\(maxcount)张，正在上传第\(count)张"
                                        if count == maxcount {
                                            hub.label.text = "上传完成"
                                            hub.hide(animated: true, afterDelay: 1)
                                            
                                            //询问是否要删除所有文件
                                            let delay = DispatchTime.now() + 1
                                            DispatchQueue.main.asyncAfter(deadline: delay) {
                                                self.deleteWarn();
                                            }
                                            
                                        } else{
                                            count = count + 1
                                        }
                                    } else {
                                        print("图片上传失败")
                                        hub.label.text = "图片上传失败"
                                        count = count + 1
                                    }
                                    
                                }
                                

                            })
                            
                       }, failure: { (err) in
                        print(err)
                        hub.hide(animated: true)
                       })
                        
                        
                    }
                    

                    
                }
            }
        
        
        
    }
    
    
    /// 删除警告
    @objc func deleteWarn(){
        let alertCtr = UIAlertController(title: "文件已传送完毕", message: "需要删除所有文件吗", preferredStyle: .alert)
        alertCtr.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (action) in
            //删除本地文件
            PhotoManager.defaultManager.deleateAllFiles()
            self.bigSoucre = []
            self.smallSoucre = []
            self.imgIndex = 0
            
            //删除数据库的记录
            
            RealmManager.realmManager.deleteAll()
            
            
            //刷新表
            self.collectionView?.reloadData()
            
        }))
        
        alertCtr.addAction(UIAlertAction(title: "暂不删除", style: .cancel, handler: { (action) in
            
            
            
        }))
        
        self.present(alertCtr, animated: true, completion: {
            
        })

    }
    
    
    
  func uploadFile(fileInfo:NSDictionary,success:@escaping ((_ request: UploadRequest)->Void),failure: @escaping (_: Error)->Void) -> Void {
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            let file = fileInfo["fileUrl"] as! URL
            let fileName = fileInfo["fileName"] as! String;
            let deviceType = fileInfo["deviceType"] as! String;
            let deviceName = fileInfo["deviceName"] as! String;
            let uuid = fileInfo["uuid"] as! String;
            let fileSize = fileInfo["fileSize"] as! NSDictionary;
            let createTime = fileInfo["createTime"] as! String;
            let markFrame = fileInfo["markFrame"] as! NSDictionary;
//            let remoteUrl = fileInfo["remoteUrl"];
            let fileSizeData = try! JSONSerialization.data(withJSONObject: fileSize, options:.prettyPrinted)
            let markFrameData = try! JSONSerialization.data(withJSONObject: markFrame, options: .prettyPrinted)
            
            multipartFormData.append(file, withName: "file")
            multipartFormData.append(fileName.data(using: .utf8)!, withName: "fileName")
            multipartFormData.append(deviceType.data(using: .utf8)!, withName: "deviceType")
            multipartFormData.append(deviceName.data(using: .utf8)!, withName: "deviceName")
            multipartFormData.append(createTime.data(using: .utf8)!, withName: "createTime")
            multipartFormData.append(uuid.data(using: .utf8)!, withName: "uuid")
            multipartFormData.append(fileSizeData, withName: "fileSize")
            multipartFormData.append(markFrameData, withName: "markFrame")

            
            
        }, to: uploadUrl, encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                success(upload)
            case .failure(let encodingError):
                failure(encodingError)
            }
            
        })

    }
    
    
    
    @objc func editClick(){
    
        if smallSoucre.count == 0 {
            editItem.title = "删除"
            editItem.isEnabled = false
            return;
        }else{
            editItem.isEnabled = true
        }
        
        if editItem.title == "删除" {
            editItem.title = "完成"
            //显示删除图标
            collectionView?.reloadItems(at: (collectionView?.indexPathsForVisibleItems)!)
        }else{
            editItem.title = "删除"
            //隐藏删除图标
            collectionView?.reloadItems(at: (collectionView?.indexPathsForVisibleItems)!)
        }
        
    }
    
    @objc func sortClick() {
        
        //条件判断
        if smallSoucre.count < 2 {
            sortItem.isEnabled = false
            return
        }
        
        
        //逻辑处理
        
        //处理数据
        if sortItem.title == "正序" {
            sortItem.title = "倒序"
            
            smallSoucre.sort(by: <)
            bigSoucre.sort(by: <)
            
            collectionView?.reloadData()
            
        }else {
            sortItem.title = "正序"
            smallSoucre.sort(by: >)
             bigSoucre.sort(by: >)
             collectionView?.reloadData()
        }
        

        
        
        
        
        
        
        
        
        
        
    }
    
    
    @objc func locateCell() {
        
        if smallSoucre.count <= 1 {
            return
        }
        
        //读取最后一个标记
        
        var index = 0;
        
        //在数组中找到index
        if let markImgName = UserDefaults.standard.string(forKey: "markIndex") {
            
            if let i = bigSoucre.index(of: markImgName) {
                
                index = i
            }
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        //滚动到指定的cell
        collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        
        
        //获取那个cell
        
        let delay = DispatchTime.now() + 0.25
        
        DispatchQueue.main.asyncAfter(deadline: delay) {
            // 你想做啥
            
            if  let cell:ImageCell = self.collectionView?.cellForItem(at: indexPath) as? ImageCell  {
                
                UIView.animate(withDuration: 0.35, animations: {
                    cell.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
                }, completion: { (yes) in
                    UIView.animate(withDuration: 0.35, animations: {
                         cell.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
                    }, completion: { (yes) in
                        cell.transform = CGAffineTransform.identity
                    })
                    
                })
                
                
            }

        }
        
        
        
        
        
    }

    
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return smallSoucre.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    
        // Configure the cell
        
        //获取路径
        
        //注意
        let filePath = PhotoManager.defaultManager.createFilePath(fileName: smallSoucre[indexPath.row])
        cell.imageView.sd_setImage(with: URL(fileURLWithPath: filePath))
        
        if editItem.title == "删除" {
            cell.deleteBtn.isHidden = true
        } else {
            cell.deleteBtn.isHidden = false
        }
        
        
        cell.deleteBlock = {
            deleteCell in
            
            if self.bigSoucre.count == 0 || self.smallSoucre.count == 0{
                return;
            }
            
            //获取当前的index
            let deleteIndex = collectionView.indexPath(for: deleteCell)!
            //从磁盘中删除原图和缩略图
            PhotoManager.defaultManager.deleateFile(name: self.bigSoucre[deleteIndex.row])
            PhotoManager.defaultManager.deleateFile(name: self.smallSoucre[deleteIndex.row])
            
            //从数据库中移除记录
            let fiter: NSPredicate = NSPredicate(format: "fileName == %@", self.bigSoucre[deleteIndex.row])
            if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
                RealmManager.realmManager.delete(item)
            }
            
            //从数据中移除
            self.bigSoucre.remove(at: deleteIndex.row)
            self.smallSoucre.remove(at: deleteIndex.row)
            
            //从界面中删除
            collectionView.deleteItems(at: [deleteIndex])
            
            self.editItem.isEnabled = self.smallSoucre.count != 0
            
        }
        
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imgIndex = indexPath.row
        
        let btmarCtr = BTMarkViewController(currentIndex:imgIndex,dataSouce:bigSoucre,smallDataSouce:smallSoucre)

        btmarCtr.updataDataSouce = {
            currentIndex,bigSoucre,smallSoucre in
            self.imgIndex = currentIndex
            self.bigSoucre = bigSoucre
            self.smallSoucre = smallSoucre
            self.collectionView?.reloadData()
            self.editItem.isEnabled = self.smallSoucre.count != 0
        }
        
        
        navigationController!.present(btmarCtr, animated: true) {
            
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let sdImageCache =  SDImageCache.shared()
        sdImageCache.clearMemory()
        sdImageCache.clearDisk(onCompletion: nil)
        
    }
    
    
    
    


}


