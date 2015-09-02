//
//  ViewController.swift
//  CHWCubeAnimation
//
//  Created by Loveway on 15/8/10.
//  Copyright (c) 2015年 Henry·Cheng. All rights reserved.
//

import UIKit
import GLKit
import QuartzCore

class ViewController: UIViewController,UIGestureRecognizerDelegate{
    
    let cube_width: CGFloat = 200
    let cube_height: CGFloat = 200
    let bgView = UIView()
    let PAI: CGFloat = CGFloat(M_PI)
    let PAI_2: CGFloat = CGFloat(M_PI_2)
    
    let imgView1 = UIImageView()
    let imgView2 = UIImageView()
    let imgView3 = UIImageView()
    let imgView4 = UIImageView()
    let imgView5 = UIImageView()
    let imgView6 = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.bounds = CGRectMake(0 , 0, cube_width, cube_height)
        bgView.layer.contentsScale = UIScreen.mainScreen().scale
        bgView.layer.position = self.view.center
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, -PAI/9, 1, 1, 0)
        transform.m34 = -1.0/2000
        bgView.layer.sublayerTransform = transform
        
        self.view.layer.addSublayer(bgView.layer)
        self.view.addSubview(bgView)
        self.creatImageView()
        
        let delay = 0.5 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            NSThread.detachNewThreadSelector(Selector("animationFirst"), toTarget:self, withObject:nil)
        })
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("handleGes:"))
        bgView.addGestureRecognizer(panGesture)
        
        
    }
    
//    开始的时候的动画
    func animationFirst() {
    let t = CATransform3DIdentity
    let cubeAnimation1 = CABasicAnimation(keyPath: "sublayerTransform")
    cubeAnimation1.duration = 0.5
    cubeAnimation1.autoreverses = false
    cubeAnimation1.fillMode = kCAFillModeBoth
    cubeAnimation1.removedOnCompletion = false
    cubeAnimation1.delegate = self
//    if bgView!.layer {
        bgView.layer.sublayerTransform = t
//    }
    bgView.layer.addAnimation(cubeAnimation1, forKey: "cubeAnimation1")
    
    }
    
//    创建视图
    func creatImageView() {
        
        var cubeArray: [UIImageView] = [imgView1,imgView2,imgView3,imgView4,imgView5,imgView6]
        
        for i in 0..<cubeArray.count {
            
            var imageView = cubeArray[i]
            imageView.tag = i + 1
            imageView.layer.contentsScale = UIScreen.mainScreen().scale
            imageView.bounds = CGRectMake(0, 0, cube_width, cube_height)
            imageView.layer.position = CGPointMake(CGRectGetMidX(bgView.bounds),CGRectGetMidY(bgView.bounds))
            
            if i == 0 {
                //front
                var transform1 = CATransform3DMakeTranslation(0, 0, cube_width/2.0)
                transform1 = CATransform3DRotate(transform1, 0, 0, 0, 0)
                imageView.layer.transform = transform1
                imageView.backgroundColor = UIColor.redColor()
                if transform1.m43 > 0 {
                    imageView.userInteractionEnabled = true
                }
            } else if i == 1 {
                //top
                var transform2 = CATransform3DMakeTranslation(0, -cube_width/2.0, 0)
                transform2 = CATransform3DRotate(transform2, -PAI_2, 1, 0, 0)
                transform2 = CATransform3DRotate(transform2, PAI, 0, 0, 1)
                transform2 = CATransform3DRotate(transform2, PAI, 0, 1, 0)
                imageView.layer.transform = transform2
                imageView.backgroundColor = UIColor.greenColor()
            } else if i == 2 {
                //bottom
                var transform3 = CATransform3DMakeTranslation(0, cube_width/2.0, 0)
                transform3 = CATransform3DRotate(transform3, PAI_2, 1, 0, 0)
                transform3 = CATransform3DRotate(transform3, PAI, 0, 0, 1)
                transform3 = CATransform3DRotate(transform3, PAI, 0, 1, 0)
                imageView.layer.transform = transform3
                imageView.backgroundColor = UIColor.cyanColor()
            } else if i == 3 {
                //left
                var transform4 = CATransform3DMakeTranslation(-cube_width/2.0, 0, 0)
                transform4 = CATransform3DRotate(transform4, -PAI_2, 0, 1, 0)
                imageView.layer.transform = transform4
                imageView.backgroundColor = UIColor.grayColor()
            } else if i == 4 {
                //right
                var transform5 = CATransform3DMakeTranslation(cube_width/2.0, 0, 0)
                transform5 = CATransform3DRotate(transform5, PAI_2, 0, 1, 0)
                imageView.layer.transform = transform5
                imageView.backgroundColor = UIColor.magentaColor()
            } else {
                //back
                var transform6 = CATransform3DMakeTranslation(0, 0, -cube_width/2.0)
                transform6 = CATransform3DRotate(transform6, 0, 0, 0, 0)
                transform6 = CATransform3DRotate(transform6, PAI, 0, 0, 1)
                transform6 = CATransform3DRotate(transform6, PAI, 0, 1, 0)
                imageView.layer.transform = transform6
                imageView.backgroundColor = UIColor.blueColor()
            }
            
            bgView.layer.addSublayer(imageView.layer)
            
            //魔方的点击事件
            let cubeRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapCube:"))
            cubeRecognizer.numberOfTapsRequired = 1
            cubeRecognizer.delegate = self
            imageView.addGestureRecognizer(cubeRecognizer)
        }
        
    }
    
//    MARK:魔方拖拽动画
    func handleGes(pan: UIPanGestureRecognizer) {
        
        let difPoint: CGPoint = pan.translationInView(bgView)
        let rotx = 1 * GLKMathDegreesToRadians(Float(difPoint.y/2.0))
        let roty = -1 * GLKMathDegreesToRadians(Float(difPoint.x/2.0))
        
        var t = CATransform3D()
        t = bgView.layer.sublayerTransform
        t = CATransform3DRotate(t, CGFloat(-rotx), 1, 0, 0)
        t = CATransform3DRotate(t, CGFloat(-roty), 0, 1, 0)
        bgView.layer.sublayerTransform = t
        
        pan.setTranslation(CGPointZero, inView: self.view)
        if pan.state == UIGestureRecognizerState.Ended {
            
            //判断哪些在前面
            let angleX = self.getXRotation(bgView.layer.sublayerTransform) - PAI_2
            let angleY = self.getYRotation(bgView.layer.sublayerTransform)
            let angleZ = self.getZRotation(bgView.layer.sublayerTransform) - PAI_2
            
            var imgArr: [UIImageView] = []
            
            if angleY < -PAI_2 || angleY > PAI_2 {
                imgArr.append(imgView6)
            } else {
                imgArr.append(imgView1)
            }
            
            if angleX < -PAI_2 || angleX > PAI_2 {
                imgArr.append(imgView2)
            } else {
                imgArr.append(imgView3)
            }
            
            if angleZ < -PAI_2 || angleZ > PAI_2 {
                imgArr.append(imgView5)
            } else {
                imgArr.append(imgView4)
            }
            
            //计算面积排序
            var sortArray: Array = imgArr.sorted({ (t1: UIView, t2: UIView) -> Bool in
                
                let s1 = self.getArea(t1)
                let s2 = self.getArea(t2)
                
                return s1 > s2
            })
            
//           var sortArray = sorted(imgArr, {(v1: UIView,v2: UIView) -> Bool in
//                let s1 = self.getArea(v1)
//                let s2 = self.getArea(v2)
//                
//                return s1 > s2
//            })
            
            let targetView = sortArray.first
            targetView!.userInteractionEnabled = true
            println("This is \(targetView!.tag)")
            let targetTag = targetView!.tag
            
            var t2 = CATransform3D()
            if targetTag == 1 {
                //front
                t2 = CATransform3DIdentity
            } else if targetTag == 2 {
                //top
                t2 = CATransform3DMakeRotation(-PAI_2, 1, 0, 0)
            } else if targetTag == 3 {
                //bottom
                t2 = CATransform3DMakeRotation(PAI_2, 1, 0, 0)
            } else if targetTag == 4 {
                //left
                t2 = CATransform3DMakeRotation(PAI_2, 0, 1, 0)
            } else if targetTag == 5 {
                //right
                t2 = CATransform3DMakeRotation(-PAI_2, 0, 1, 0)
            } else if targetTag == 6 {
                //back
                t2 = CATransform3DMakeRotation(PAI, 1, 0, 0)
            }
            
            let animation = CABasicAnimation(keyPath: "sublayerTransform")
            animation.duration = 0.3
            animation.autoreverses = false
            animation.removedOnCompletion = false
            animation.delegate = self
            animation.fillMode = kCAFillModeForwards
            bgView.layer.sublayerTransform = t2
            bgView.layer.addAnimation(animation, forKey: "animation")
        }
    }
    
//    MARK:魔方的点击事件
    func tapCube(tap: UITapGestureRecognizer) {
        
    }
    
//    MARK:获得面积
    private func getArea(view: UIView) -> CGFloat {
        let width = cube_width
        
        let p1 = view.convertPoint(CGPointMake(0, 0), toView: self.view)
        let p2 = view.convertPoint(CGPointMake(width, 0), toView: self.view)
        let p3 = view.convertPoint(CGPointMake(0, width), toView: self.view)
        
        let a: CGFloat = pow(pow(p1.x - p3.x, 2) + pow(p1.y - p3.y, 2), 0.5)
        let b: CGFloat = pow(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2), 0.5)
        let c: CGFloat = pow(pow(p3.x - p2.x, 2) + pow(p3.y - p2.y, 2), 0.5)
        let p: CGFloat = (a + b + c)/2
        
        let h: CGFloat = 2*sqrt(p*(p - a)*(p - b)*(p - c))/b
        let S: CGFloat = b*h
        return S
    }
    
/// 获得x轴的旋转角度
    private func getXRotation(t:CATransform3D) -> CGFloat {
        
        return atan2(t.m23, t.m22)
    }
/// 获得x轴的旋转角度
    private func getYRotation(t:CATransform3D) -> CGFloat {
        
        return atan2(t.m31, t.m33)
    }
/// 获得x轴的旋转角度
    private func getZRotation(t:CATransform3D) -> CGFloat {
        
        return atan2(t.m12, t.m11)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

