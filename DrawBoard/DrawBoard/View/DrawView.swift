//
//  DrawView.swift
//  DrawBoard
//
//  Created by 峰 on 2020/4/24.
//  Copyright © 2020 峰. All rights reserved.
//

import UIKit
protocol Drawable {
    func appear(in rect: CGRect)
}

extension UIImage: Drawable {
    func appear(in rect: CGRect) {
        draw(in: rect)
    }
}

class FFPath: UIBezierPath, Drawable {
    var lineColor = UIColor.black
    func appear(in rect: CGRect) {
        lineColor.set()
        stroke()
    }
}

@objcMembers class DrawView: UIView, DrawImageViewDelegate{
    // 当前绘制的路径
    var path = FFPath()
    var lineWidth : CGFloat = 1
    var lineColor = UIColor.black
    
    lazy var drawArray = Array<Drawable>()     // 存储着图片或着是路径
    
    override func awakeFromNib() {
        setUp()
    }
    
    // 初始化
    private func setUp() {
        DrawView.addBorderAndShadow(layer)
        // 添加拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        self.addGestureRecognizer(pan)
    }
    
    // 绘制
    override func draw(_ rect: CGRect) {
        for draw in drawArray {
            draw.appear(in: rect)
        }
    }
    
    // 给某个layer添加描边和阴影
    class func addBorderAndShadow(_ layer: CALayer){
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        // 描线
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
    }
    
    // MARK:- 手势实现
    @objc private func pan(pan: UIPanGestureRecognizer) {
        // 获取当前点
        let curP = pan.location(in: self)
        
        if pan.state == .began {
            path = FFPath()
            path.lineWidth = lineWidth
            path.lineColor = lineColor
            path.move(to: curP)
            drawArray.append(path)
        } else if pan.state == .changed {
            path.addLine(to: curP)
        }
        setNeedsDisplay()
    }
    
    // MARK:- 代理
    func drawImageView(_ drawImageView: DrawImageView, didLongPress image: UIImage) {
        // 去掉那个View
        drawImageView.removeFromSuperview()
        drawArray.append(image)
        setNeedsDisplay()
    }
    
    // MARK:- 操作
    /// 添加图片
      func addImage(_ image: UIImage) {
          let drawImageView = DrawImageView(frame: bounds)
          addSubview(drawImageView)
          drawImageView.image = image
          drawImageView.delegate = self
      }
      
      /// 清空
      func clear() {
          if drawArray.count > 0 {
              drawArray.removeAll()
              setNeedsDisplay()
          }
      }
      
      /// 撤销
      func removeLast() {
          if drawArray.count > 0 {
              drawArray.removeLast()
              setNeedsDisplay()
          }
      }
      
      /// 橡皮擦
      func erase() {
          lineColor = backgroundColor!
      }
}

