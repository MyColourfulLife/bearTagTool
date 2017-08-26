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
    
    
    var dataSource:Array<String> = PhotoManager.defaultManager.getImgList(path: PhotoManager.defaultManager.createImageSandBoxPath())!
    
    var markView: MarkView!
    
    
    var imgIndex:Int!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.white
        title = "图片采集库"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareClick))
            
//            UIBarButtonItem(title: "分享", style: .done, target: self, action: #selector(shareClick))
        
        markView = MarkView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 40))
        collectionView?.addSubview(markView)
        markView.alpha = 0
        
        markView.leftBtn.addTarget(self, action: #selector(clickLeft(leftBtn:)), for: .touchUpInside)
        markView.rightBtn.addTarget(self, action: #selector(clickRight(rightBtn:)), for: .touchUpInside)
        imgIndex = 0
    }
    
    
    /// 分享按钮
    func shareClick() {
        let databaseToShare = RealmManager.realmManager.realm.configuration.fileURL!
        var items = [databaseToShare]
        //imgToShare
        if dataSource.count > 0 {
            for imgName in dataSource {
                let imgPath = PhotoManager.defaultManager.createFilePath(fileName: imgName)
                items.append(URL(fileURLWithPath: imgPath))
            }
        }
        
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
   
            
            
        }
    

        self.present(activityVC, animated: true, completion: { () -> Void in
            
        })
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    
        // Configure the cell
        
        //获取路径
        
        //注意
        let filePath = PhotoManager.defaultManager.createFilePath(fileName: dataSource[indexPath.row])
        cell.imageView.sd_setImage(with: URL(fileURLWithPath: filePath))
        
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //检查
        checkLeftAndRightIsNeedShow(index:indexPath.row)
        //动画出现
        
        // 让大图从小图的位置和大小开始出现
        let origin = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + 64)
        let originFram: CGRect = CGRect.init(origin: origin, size: markView.bigImageView.bounds.size);
        
        let cell = collectionView.cellForItem(at: indexPath)
        let cellInColltionView = collectionView.convert((cell?.frame)!, to: collectionView)
        
        self.markView.frame = cellInColltionView
        
//        self.markView.frame = (cell?.frame)!
        
        UIView.animate(withDuration: 0.25) { 
            self.markView.alpha = 1
            self.markView.frame = originFram
        }
        
        collectionView.isScrollEnabled = false
        imgIndex = indexPath.row
        
        fillMarkViewWithIndex(index:imgIndex)
        
         drawRectUp(imgname: dataSource[imgIndex])
        
    }
    

    //向左
    func clickLeft(leftBtn:UIButton) {
        
        imgIndex = imgIndex - 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        fillMarkViewWithIndex(index:imgIndex)
        
        markView.clean()
        
        drawRectUp(imgname: dataSource[imgIndex])
        
        
    }
    
    //向右
    func clickRight(rightBtn:UIButton) {
        imgIndex = imgIndex + 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        
        fillMarkViewWithIndex(index:imgIndex)
        
        markView.clean()
        
        drawRectUp(imgname: dataSource[imgIndex])
    }
    
    
    func drawRectUp(imgname:String) {
        markView.rectView?.removeFromSuperview()
        markView.rectView = nil
        //更新frame
        let fiter: NSPredicate = NSPredicate(format: "fileName == %@", imgname)
        if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
            if let frame = item.frame {
                let rectFrame = CGRect(x: frame.x, y: frame.y - 64, width: frame.width, height: frame.height)
                markView.rectView = RectView(frame:rectFrame)
                markView.addSubview(markView.rectView!)
            }
        }
    }
    
    
    func fillMarkViewWithIndex(index:Int) {
        let filePath = PhotoManager.defaultManager.createFilePath(fileName: dataSource[index])
        self.markView.bigImageView.sd_setImage(with: URL(fileURLWithPath: filePath))

        self.markView.bigImageView.layer.removeAnimation(forKey: "fade")
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.markView.bigImageView.layer.add(transition, forKey: "fade")
        
    }
    

    
    func checkLeftAndRightIsNeedShow(index:Int) {
        if index == 0 {
            markView.leftBtn.isHidden = true
        } else if index == dataSource.count - 1 {
            markView.rightBtn.isHidden = true
        } else {
            markView.rightBtn.isHidden = false
            markView.leftBtn.isHidden = false
        }

    }
    


}


