//
//  MarkViewController.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/25.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit

class MarkViewController: UIViewController {

    var showImage: UIImageView!
    var cancelBtn:UIButton!
    var doneBtn:UIButton!
    var cleanBtn:UIButton!
    
    
    var imgPath:String!
    var imgName:String!
    var compImgPath:String!
    
    
    
    var startPoint:CGPoint = CGPoint.zero
    var endPoint:CGPoint = CGPoint.zero
    var rectView:RectView?
    
    var lastFrame: CGRect?
    
    

 
    
    
    init(imagePath:String,comperssImgPath:String) {
        imgPath = imagePath
        compImgPath = comperssImgPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
      
        initView()
        showImage.sd_setImage(with: URL(fileURLWithPath: imgPath))

        //添加事件
        addEvent()
        
    }

    
    /// 添加事件
    func addEvent() {
        cancelBtn.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
        cleanBtn.addTarget(self, action: #selector(clean), for: .touchUpInside)
    }
    

    /// 初始化视图
    func initView() {
    //顶部栏视图
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
        
        showImage = UIImageView()
        view.addSubview(showImage)
        showImage.isUserInteractionEnabled = true
        showImage.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(64)
        }
        
        // 左边返回按钮  右边确定按钮
        
        cancelBtn = UIButton(type: .roundedRect)
        doneBtn = UIButton(type: .roundedRect)
        cleanBtn = UIButton(type: .roundedRect)
        cancelBtn.setTitle("返回", for: .normal)
        doneBtn.setTitle("完成", for: .normal)
        cleanBtn.setTitle("清除", for: .normal)
        cancelBtn.backgroundColor = UIColor.black
        doneBtn.backgroundColor = UIColor.black
        cleanBtn.backgroundColor = UIColor.black
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.masksToBounds = true
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        cleanBtn.layer.cornerRadius = 5
        cleanBtn.layer.masksToBounds = true
        cleanBtn.isHidden = true
        doneBtn.isHidden = true
        
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        view.addSubview(cleanBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-80)
            make.bottom.equalTo(view).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        doneBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(80)
            make.bottom.equalTo(view).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        cleanBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
    }
    
    
    
    
    // MARK: 画框
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first else {
            return
        }
        //获取开始点位置
        startPoint =  touchPoint.location(in: showImage)
//        print("startPoint:\(startPoint)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if rectView != nil {
            return
        }
        
        //获取结束点的位置
        guard let movePoint = touches.first else {
            return
        }
        endPoint = movePoint.location(in: showImage)
        
//        print("endPoint:\(endPoint)")
        //取两个点x和y的最小值作为 绘画起点， x和y最大值 作为会话终点
        let newStart = CGPoint(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y))
        
//        let newEnd = CGPoint(x: max(startPoint.x, endPoint.x), y: max(startPoint.y, endPoint.y))
        
        //画一个矩形添加到layer上
        let width = abs(endPoint.x - startPoint.x)
        let height = abs(endPoint.y - startPoint.y)
        
        guard width >= 30 && height >= 30 else {
            return
        }
//        let originPoint = startPoint.y < endPoint.y ? startPoint : endPoint
        
        let frame = CGRect(origin: newStart, size: CGSize(width: width, height: height))
        rectView = RectView(frame:frame)
        showImage.addSubview(rectView!)
        lastFrame = rectView?.frame
        
        rectView?.panGestureEndedClosure = {
            self.lastFrame = self.rectView?.frame
//            print("移动后\(self.lastFrame!)")
        }
        
         cleanBtn.isHidden = false
         doneBtn.isHidden  = false
    }


    // MARK: - 事件处理
    
    
    /// 点击了返回按钮 文件不保存
    @objc func cancelClick() {
        //删除文件
        PhotoManager.defaultManager.deleateFile(path: imgPath)
        //删除缩略图
        PhotoManager.defaultManager.deleateFile(path: compImgPath)
        //从数据库中移除
        let fiter: NSPredicate = NSPredicate(format: "fileName == %@", imgName)
        
        if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
            RealmManager.realmManager.delete(item)
        }

        
        dismiss(animated: true) {
            
        }
    }
    
    /// 点击了完成按钮
    @objc func doneClick() {
        //保存标注信息
       let frame = FramePostion(value: [lastFrame!.origin.x,lastFrame!.origin.y,lastFrame!.size.width,lastFrame!.size.height])
        //更新frame
        let fiter: NSPredicate = NSPredicate(format: "fileName == %@", imgName)
        if let item =  RealmManager.realmManager.realm.objects(PhotoItem.self).filter(fiter).first{
            RealmManager.realmManager.doWriteHandler {
            item.frame = frame
            }
        }
        
        UserDefaults.standard.setValue(imgName, forKey: "markIndex")
        
        
        dismiss(animated: true) {
        }
    }
    
    
    @objc func clean() {
        rectView?.removeFromSuperview()
        rectView = nil
        cleanBtn.isHidden = true
        doneBtn.isHidden = true
    }
    
    
}



