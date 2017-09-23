//
//  RectView.swift
//  bearTagTool
//
//  Created by 黄家树 on 2017/8/25.
//  Copyright © 2017年 com.id-bear. All rights reserved.
//

import UIKit

class RectView: UIView {
    
    //拖动手势结束的回调
    typealias PanGestrueEndedClosure = ()->()
    
    var panGestureEndedClosure: PanGestrueEndedClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initliazsiton()
        self.addGesture()
    }
    
    
    func initliazsiton() {
        let path = UIBezierPath(rect: self.bounds)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = path.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        self.layer.addSublayer(shapeLayer)
    }
    
    
    func addGesture() {
        //添加拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        self.addGestureRecognizer(panGesture)
    }
    
    
    @objc func handlePanGesture(gesture:UIPanGestureRecognizer) {
        //获取拖动位置的中心
        if self.superview != nil {
            var center = self.center
            
            let point = gesture.translation(in: self)
            center.x += point.x
            center.y += point.y
            self.center = center
            gesture.setTranslation(CGPoint.zero, in: self)
        }
        
        
        if gesture.state == .ended {
            if let panGestureEndedClosure = self.panGestureEndedClosure{
                panGestureEndedClosure()
            }
            
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("我走了 啊")
    }
    
}

