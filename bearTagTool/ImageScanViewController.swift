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

private let reuseIdentifier = "Cell"

class ImageScanViewController: UICollectionViewController {
    
    var smallSoucre:Array<String> = []
    var bigSoucre:Array<String> = []
    
    var imgIndex:Int!
    
    var editItem:UIBarButtonItem!

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
        
        // Register cell classes
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.white
        title = "图片采集库"
        
        let sharetem  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareClick))
        editItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action:  #selector(editClick))
        editItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray], for: .disabled)
        navigationItem.rightBarButtonItems = [sharetem,editItem]
        
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
                for imgName in self.bigSoucre {
                    let imgPath = PhotoManager.defaultManager.createFilePath(fileName: imgName)
                    items.append(URL(fileURLWithPath: imgPath))
                }
            }
            
            
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


