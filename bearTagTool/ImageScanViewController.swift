//
//  ImageScanViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SDWebImage

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
        
        markView = MarkView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 40))
        collectionView?.addSubview(markView)
        markView.alpha = 0
        
        markView.leftBtn.addTarget(self, action: #selector(clickLeft(leftBtn:)), for: .touchUpInside)
        markView.rightBtn.addTarget(self, action: #selector(clickRight(rightBtn:)), for: .touchUpInside)
        imgIndex = 0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        //赋值
        fillMarkViewWithIndex(index:indexPath.row)
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
        
    }
    

    //向左
    func clickLeft(leftBtn:UIButton) {
        
        imgIndex = imgIndex - 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        fillMarkViewWithIndex(index:imgIndex)
        
    }
    
    //向右
    func clickRight(rightBtn:UIButton) {
        imgIndex = imgIndex + 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        fillMarkViewWithIndex(index:imgIndex)
    }
    
    
    func fillMarkViewWithIndex(index:Int) {
        let filePath = PhotoManager.defaultManager.createFilePath(fileName: dataSource[index])
        markView.bigImageView.sd_setImage(with: URL(fileURLWithPath: filePath))
    }
    
    
    
    func checkLeftAndRightIsNeedShow(index:Int) {
        if imgIndex == 0 {
            markView.leftBtn.isHidden = true
        } else if imgIndex == dataSource.count - 1 {
            markView.rightBtn.isHidden = true
        } else {
            markView.rightBtn.isHidden = false
            markView.leftBtn.isHidden = false
        }

    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


