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
let uploadUrl = "http://192.168.1.170:8080/api/upload"

class ImageScanViewController: UICollectionViewController {
    
    var smallSoucre:Array<String> = []
    var bigSoucre:Array<String> = []
    
    var imgIndex:Int!
    
    var editItem:UIBarButtonItem!

    var sortItem:UIBarButtonItem!
    
    var locateCellBtn:UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        editItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray], for: .disabled)
        
        sortItem = UIBarButtonItem(title: "正序", style: .plain, target: self, action:  #selector(sortClick))
        sortItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray], for: .disabled)
        
       locateCellBtn = UIBarButtonItem(title: "定位", style: .plain, target: self, action:  #selector(locateCell))
        
        navigationItem.rightBarButtonItems = [sharetem,editItem,sortItem,locateCellBtn]
        
        
        editItem.isEnabled = smallSoucre.count != 0
    }
    
    
    
    
    
    /// 分享按钮
    func shareClick() {
        
        
        let alertCtr = UIAlertController(title: "温馨提醒", message: "此功能将一键导出标注图片和标注文件，导出后将删除本地文件", preferredStyle: .alert)
        alertCtr.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
            
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
                    items.append(URL(fileURLWithPath: imgPath))
                    
//类型可以使用 mimeType:"application/octet-stream"
                    Alamofire.upload(multipartFormData: { (multipartFormData) in
                        
                        multipartFormData.append(fileUrl, withName: "file")
                        multipartFormData.append("姓名".data(using: .utf8)!, withName: "userName")

                    }, to: uploadUrl, encodingCompletion: { encodingResult in
                        
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.uploadProgress{ progress in // main queue by default
                                print("Upload Progress: \(progress.fractionCompleted)")
                            }.responseJSON { response in
                                debugPrint(response)
                                hub.progress = Float(count)/Float(maxcount)
                                hub.label.text = "共\(maxcount)张，正在上传第\(count)张"
                                if count == maxcount {
                                    hub.label.text = "上传完成"
                                    hub.hide(animated: true, afterDelay: 1)
                                }
                                count = count + 1
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                            hub.hide(animated: true)
                        }
                        
                    })
                    
                }
            }
            
            

            
            
            return;
            let activityVC = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil)
            activityVC.completionWithItemsHandler =  { activity, success, items, error in
                
                //分享成功删除数据
                if success {
                    
                    //删除本地文件
                    PhotoManager.defaultManager.deleateAllFiles()
                    self.bigSoucre = []
                    self.smallSoucre = []
                    self.imgIndex = 0
                    
                    //删除数据库的记录
                    
                    RealmManager.realmManager.deleteAll()
                    
                    
                    //刷新表
                    self.collectionView?.reloadData()
                    
                }
                
            }
            
            
            self.present(activityVC, animated: true, completion: { () -> Void in
                
            })

            
        }))
        
        alertCtr.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
           
            
            
        }))
        
        
        present(alertCtr, animated: true, completion: { 
            
        })
        
        
        
    }
    
    
    func editClick(){
    
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
    
    func sortClick() {
        
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
    
    
    func locateCell() {
        
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


