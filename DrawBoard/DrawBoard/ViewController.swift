//
//  ViewController.swift
//  DrawBoard
//
//  Created by 峰 on 2020/4/24.
//  Copyright © 2020 峰. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var drawV: DrawView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawV.lineWidth = 1 // 这里的1 和 滑条的最小值对应
    }
    
    
    // 清空
    @IBAction func clear(_ sender: UIButton) {
        drawV.clear()
    }
    
    // 撤销
    @IBAction func removeLast(_ sender: UIButton) {
        drawV.removeLast()
    }
    
    /// 橡皮擦
    @IBAction func erase(_ sender: UIButton) {
        drawV.erase()
    }
    
    /// 线宽
    @IBAction func setLineColor(_ button: UIButton) {
        drawV.lineColor = button.backgroundColor!
    }
    
    /// 设置线的宽度
    @IBAction func setLineWidth(_ slider: UISlider) {
        drawV.lineWidth = CGFloat(slider.value)
    }
    
     /// 保存
     @IBAction func save(_ button: UIButton) {
       
        saveButton.isEnabled = false
        
         // 开启上下文
         UIGraphicsBeginImageContextWithOptions(drawV.frame.size, true, 0)
         // 绘制
         self.drawV.layer .render(in: UIGraphicsGetCurrentContext()!)
         // 导出
         let image = UIGraphicsGetImageFromCurrentImageContext()!
         // 关闭上下文
         UIGraphicsEndImageContext()
         // 保存图片
         UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image: didFinishSavingWithError: contextInfo:)), nil)
         
         
     }
     
     @objc private func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        saveButton.isEnabled = true // 按钮可点击
    
        var title : String
        if didFinishSavingWithError == nil {
            title = "保存成功！"
        } else {
            title = "保存失败！"
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
     }
    
    /// 访问相册
    @IBAction func PresentPhotoViewController(_ sender: Any) {
        let pickVC = UIImagePickerController()
        pickVC.sourceType = .savedPhotosAlbum
        pickVC.delegate = self
        present(pickVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage]! as! UIImage
    
        // 添加图片
        drawV.addImage(selectedImage)
        // 图片选择器消失
        picker.dismiss(animated: true, completion: nil)
    }
}

