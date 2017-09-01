//
//  MarkView.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/24.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit
import SnapKit

class MarkView: UIView {
    
    var bigImageView: UIImageView!
    var leftBtn: UIButton!
    var rightBtn: UIButton!
    var startPoint:CGPoint = CGPoint.zero
    var endPoint:CGPoint = CGPoint.zero
    var rectView:RectView?
    var cancelBtn:UIButton!
    var doneBtn:UIButton!
    var cleanBtn:UIButton!
    
    var lastFrame: CGRect?
    
    typealias GoBackClickBlock = ()->()
    var goBackClick: GoBackClickBlock?
    typealias DoneClickBlock = ()->()
    var doneClickBlock: DoneClickBlock?
    
    override init(frame: CGRect) {
        
        bigImageView = UIImageView()
        leftBtn = UIButton(type: .custom)
        rightBtn = UIButton(type: .custom)
        cleanBtn = UIButton(type: .roundedRect)
        
//        leftBtn.setTitle("向左", for: .normal)
//        rightBtn.setTitle("向右", for: .normal)
        
        leftBtn.setImage(#imageLiteral(resourceName: "left"), for: .normal)
        rightBtn.setImage(#imageLiteral(resourceName: "right"), for: .normal)
        
        
        super.init(frame: frame)
        addSubview(bigImageView)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        
        bigImageView.isUserInteractionEnabled = true
        
        let maskView = UIView()//用来遮挡快速切换时 为CollectionView的背景
        insertSubview(maskView, belowSubview: bigImageView)
        maskView.backgroundColor = UIColor.lightGray
        maskView.snp.makeConstraints { (make) in
            make.top.bottom.right.left.equalTo(bigImageView)
        }
        
        
        bigImageView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
      
        
        leftBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(bigImageView)
            make.left.equalTo(10)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.size.equalTo(leftBtn)
            make.centerY.equalTo(leftBtn)
            make.right.equalTo(-10)
        }
        
        // 左边返回按钮  右边确定按钮
        
        cancelBtn = UIButton(type: .roundedRect)
        doneBtn = UIButton(type: .roundedRect)
        cleanBtn = UIButton(type: .roundedRect)
        cancelBtn.setTitle("还原", for: .normal)
        doneBtn.setTitle("修改", for: .normal)
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
        
        
        addSubview(cancelBtn)
        addSubview(doneBtn)
        addSubview(cleanBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).offset(-80)
            make.bottom.equalTo(self).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        doneBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self).offset(80)
            make.bottom.equalTo(self).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        cleanBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }

        cancelBtn.addTarget(self, action: #selector(clickGoBack), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
        cleanBtn.addTarget(self, action: #selector(clean), for: .touchUpInside)
        
        cancelBtn.isHidden = true
        doneBtn.isHidden = true
        cleanBtn.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    // MARK: - 事件处理
    
    
    /// 点击了还原按钮
    
    
//    makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void)
    
    func clickGoBack() {
        if goBackClick != nil {
            goBackClick!()
            
            
        }
    }
    
    
    /// 点击了完成按钮
    func doneClick() {
        if doneClickBlock != nil {
            doneClickBlock!()
            
        }
    }
    
    func clean() {
        rectView?.removeFromSuperview()
        rectView = nil
        cleanBtn.isHidden = true
        doneBtn.isHidden = true
    }
    
    // MARK: 画框
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first else {
            return
        }
        

        
        //获取开始点位置
        
        startPoint =  touchPoint.location(in: self)
//        print("startPoint:\(startPoint)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if rectView != nil  || bigImageView.image == nil {
            return
        }
        
        //获取结束点的位置
        guard let movePoint = touches.first else {
            return
        }
        endPoint = movePoint.location(in: self)
        
//        print("endPoint:\(endPoint)")
        
        //画一个矩形添加到layer上
        let width = abs(endPoint.x - startPoint.x)
        let height = abs(endPoint.y - startPoint.y)
        
        guard width >= 30 && height >= 30 else {
            return
        }
        let originPoint = CGPoint(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y))

        let frame = CGRect(origin: originPoint, size: CGSize(width: width, height: height))
        rectView = RectView(frame:frame)
        addSubview(rectView!)
        lastFrame = rectView?.frame
        
        rectView?.panGestureEndedClosure = {
            self.lastFrame = self.rectView?.frame
//            print("移动后\(self.lastFrame!)")
        }
        
        doneBtn.setTitle("完成", for: .normal)
        cleanBtn.isHidden = false
        doneBtn.isHidden = false
        cancelBtn.isHidden = true
        
        bringSubview(toFront: leftBtn)
        bringSubview(toFront: rightBtn)
        
    }
    
   
    

    
}
