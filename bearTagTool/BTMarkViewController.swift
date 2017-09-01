//
//  BTMarkViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/9/1.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import MBProgressHUD

class BTMarkViewController: UIViewController {

    typealias UpdataDataSouce = (Int,Array<String>,Array<String>)->()
    
    var updataDataSouce : UpdataDataSouce?
    
    
    var markView: MarkView! //图片标注在这里进行
    var imgIndex:Int       //标记当期那是哪个图片
    var bigSoucre:Array<String>//数据源
    var smallSoucre:Array<String> //删图片的时候会用到
    
    init(currentIndex:Int,dataSouce:Array<String>,smallDataSouce:Array<String>) {
        imgIndex = currentIndex
        bigSoucre = dataSouce
        smallSoucre = smallDataSouce
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化背景色为白色
        view.backgroundColor = UIColor.white
        //初始化视图
        initView()

        
        //检查//画图
        checkLeftAndRightIsNeedShow(index:imgIndex)
        fillMarkViewWithIndex(index:imgIndex)
        drawRectUp(imgname: bigSoucre[imgIndex])
        
        //回调处理
        //点击了完成按钮
        markView.doneClickBlock = {
            //保存记录
            //保存标注信息
            let frame = FramePostion(value: [self.markView.lastFrame!.origin.x,self.markView.lastFrame!.origin.y,self.markView.lastFrame!.size.width,self.markView.lastFrame!.size.height])
            //更新frame
            let fiter: NSPredicate = NSPredicate(format: "fileName == %@", self.bigSoucre[self.imgIndex])
            if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
                RealmManager.realmManager.doWriteHandler {
                    item.frame = frame
                }
            }
            //提示保存成功
            let hub = MBProgressHUD.showAdded(to: self.markView, animated: true)
            hub.label.text = "保存成功"
            hub.mode = .text
            hub.removeFromSuperViewOnHide = true
            hub.hide(animated: true, afterDelay: 0.5)
            
            //更改图标状态
            self.markView.cancelBtn.setTitle("还原", for: .normal)
            self.markView.doneBtn.setTitle("修改", for: .normal)
            self.markView.cancelBtn.isHidden = false
            
            
        }
        
        //点击了还原按钮
        markView.goBackClick = {
            // 1. 清除标注信息
            self.markView.clean()
            // 2. 重写读取数据绘图
            self.drawRectUp(imgname: self.bigSoucre[self.imgIndex])
        }

        
        
        
    }
    
    
    func initView() {
        //添加导航栏
        let navLable = UILabel()
        view.addSubview(navLable)
        navLable.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        navLable.text = "小熊标注工具"
        navLable.textAlignment = .center
        navLable.font = UIFont.boldSystemFont(ofSize: 17)
        
          //添加关闭和删除按钮
        let closeBtn = UIButton(type: .custom)
        let deleteBtn = UIButton(type: .custom)
        
        closeBtn.setTitle("关闭", for: .normal)
        deleteBtn.setTitle("删除", for: .normal)
        
        closeBtn.setTitleColor(UIColor.blue, for: .normal)
        deleteBtn.setTitleColor(UIColor.blue, for: .normal)
        
        
        
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteFile), for: .touchUpInside)
        
        view.addSubview(closeBtn)
        view.addSubview(deleteBtn)
        
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        
        deleteBtn.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 80, height: 40))
        }
        
        
        //增加标注视图
        markView = MarkView()
        view.addSubview(markView)
        
        markView.snp.makeConstraints { (make) in
            make.top.equalTo(navLable.snp.bottom)
            make.bottom.equalTo(view.snp.bottom)
            make.left.right.equalTo(view)
        }
        
        markView.leftBtn.addTarget(self, action: #selector(clickLeft(leftBtn:)), for: .touchUpInside)
        markView.rightBtn.addTarget(self, action: #selector(clickRight(rightBtn:)), for: .touchUpInside)
        
    }
    
  
    func close() {
        
        //更新下数据源
        if updataDataSouce != nil {
            updataDataSouce!(imgIndex,bigSoucre,smallSoucre)
        }
        
        
        dismiss(animated: true) {
            
        }
        
        
    }
    
    
    
    func deleteFile() {
        
        if bigSoucre.count == 0 {
            
            UIView.animate(withDuration: 0.25, animations: { 
                self.markView.bigImageView.image = nil
                self.markView.clean()
            })
            
            return;
        }
        
        //从磁盘中删除原图和缩略图
        PhotoManager.defaultManager.deleateFile(name: self.bigSoucre[imgIndex])
        PhotoManager.defaultManager.deleateFile(name: self.smallSoucre[imgIndex])
        
        //从数据库中移除记录
        let fiter: NSPredicate = NSPredicate(format: "fileName == %@", self.bigSoucre[imgIndex])
        if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
            RealmManager.realmManager.delete(item)
        }
        
        //从数据中移除
        self.bigSoucre.remove(at: imgIndex)
        self.smallSoucre.remove(at: imgIndex)
        
        if self.imgIndex + 1 <= self.bigSoucre.count - 1 {
            self.imgIndex = self.imgIndex + 1
        } else if self.imgIndex - 1 >= 0 {
            self.imgIndex = self.imgIndex - 1
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.markView.bigImageView.image = nil
                self.markView.clean()
            })
            
            return
        }
        
        //填充图片
        checkLeftAndRightIsNeedShow(index:imgIndex)
        fillMarkViewWithIndex(index:imgIndex)
        drawRectUp(imgname: bigSoucre[imgIndex])
        
    }
    
    //向左
    func clickLeft(leftBtn:UIButton) {
        
        imgIndex = imgIndex - 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        fillMarkViewWithIndex(index:imgIndex)
        
        markView.clean()
        
        drawRectUp(imgname: bigSoucre[imgIndex])
        
        
    }
    
    //向右
    func clickRight(rightBtn:UIButton) {
        imgIndex = imgIndex + 1
        
        checkLeftAndRightIsNeedShow(index: imgIndex)
        
        fillMarkViewWithIndex(index:imgIndex)
        
        markView.clean()
        
        drawRectUp(imgname: bigSoucre[imgIndex])
    }
    

    /// 判断是否显示左右箭头
    ///
    /// - Parameter index: 所处位置
    func checkLeftAndRightIsNeedShow(index:Int) {
        
        if bigSoucre.count == 1 {
            markView.rightBtn.isHidden = true
            markView.leftBtn.isHidden = true
        } else if index == 0 {
            markView.leftBtn.isHidden = true
            markView.rightBtn.isHidden = false
        } else if index == bigSoucre.count - 1 {
            markView.leftBtn.isHidden = false
            markView.rightBtn.isHidden = true
        } else {
            markView.rightBtn.isHidden = false
            markView.leftBtn.isHidden = false
        }
        
    }
    
    /// 填充图片信息
    ///
    /// - Parameter index: 第几张图
    func fillMarkViewWithIndex(index:Int) {
        let filePath = PhotoManager.defaultManager.createFilePath(fileName: bigSoucre[index])
        self.markView.bigImageView.sd_setImage(with: URL(fileURLWithPath: filePath))
        
        self.markView.bigImageView.layer.removeAnimation(forKey: "fade")
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "moveIn"
        transition.subtype = "right"
        self.markView.bigImageView.layer.add(transition, forKey: "fade")
        
    }
    
    /// 更新绘图
    ///
    /// - Parameter imgname: 图片名称
    func drawRectUp(imgname:String) {
        markView.rectView?.removeFromSuperview()
        markView.rectView = nil
        //更新frame
        let fiter: NSPredicate = NSPredicate(format: "fileName == %@", imgname)
        if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
            if let frame = item.frame {
                let rectFrame = CGRect(x: frame.x, y: frame.y, width: frame.width, height: frame.height)
                markView.rectView = RectView(frame:rectFrame)
                markView.addSubview(markView.rectView!)
                markView.insertSubview(markView.rectView!, belowSubview: markView.doneBtn)
                markView.lastFrame = rectFrame
                markView.rectView?.panGestureEndedClosure = {
                    self.markView.lastFrame = self.markView.rectView?.frame
                    //                    print("移动后\(self.markView.lastFrame!)")
                }
                // 还原 清除 和 修改
                markView.doneBtn.setTitle("修改", for: .normal)
                markView.doneBtn.isHidden = false
                markView.cleanBtn.isHidden = false
                markView.cancelBtn.isHidden = false
            } else {
                markView.doneBtn.isHidden = true
                markView.cleanBtn.isHidden = true
                markView.cancelBtn.isHidden = true
            }
        }
    }
    
}
