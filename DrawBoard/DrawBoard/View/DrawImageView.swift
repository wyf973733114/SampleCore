//
//  DrawImageView.swift
//  DrawBoard
//
//  Created by 峰 on 2020/4/27.
//  Copyright © 2020 峰. All rights reserved.
//

import UIKit

protocol DrawImageViewDelegate{
    func drawImageView(_ drawImageView: DrawImageView, didLongPress image: UIImage)
}

class DrawImageView: UIView, UIGestureRecognizerDelegate {
    // 代理，传出调整后的图片给代理
    var delegate: DrawImageViewDelegate?
    // 外界由传入图片
    var image: UIImage? {
        set{
            imageV.image = newValue
            imageV.isUserInteractionEnabled = true
            addGesture()
            addSubview(imageV) // 传入图片后才会有imageV
        }
        get{
            return imageV.image
        }
    }
    private lazy var imageV = UIImageView(frame: self.frame)
    /// 添加长按手势
    private func addGesture() {
        // 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        imageV.addGestureRecognizer(longPress)
        
        // 拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        imageV.addGestureRecognizer(pan)
        
        // 捏合手势
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        imageV.addGestureRecognizer(pinch)
        
        // 旋转手势
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(rotation(_:)))
        imageV.addGestureRecognizer(rotation)
        
        // 设置代理让捏合和缩放可以同时使用
        pinch.delegate = self
        rotation.delegate = self
    }
    
    // MARK:- 手势实现
    // 长按时将参数传给代理
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == UIGestureRecognizer.State.began {
            UIView.animate(withDuration: 0.1, animations: {
                self.imageV.alpha = 0.5
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.imageV.alpha = 1
                })
            }
        }
        if longPress.state == UIGestureRecognizer.State.ended {
            // 开启图片上下文
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let layerImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            // 导出图片
            delegate?.drawImageView(self, didLongPress: layerImage!)
        }
    }
    /// 拖拽手势
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view!)
        pan.view!.transform = pan.view!.transform.translatedBy(x: translation.x, y: translation.y)
        pan.setTranslation(.zero, in: pan.view!)
    }
    /// 捏合手势
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        pinch.view!.transform = pinch.view!.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        pinch.scale = 1
    }
    /// 旋转手势
    @objc private func rotation(_ rotation: UIRotationGestureRecognizer) {
        rotation.view!.transform = rotation.view!.transform.rotated(by: rotation.rotation)
        rotation.rotation = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 裁剪多余的部分
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    // 同时响应捏合和旋转
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
