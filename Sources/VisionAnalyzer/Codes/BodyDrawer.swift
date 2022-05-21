////
////  BodyDrawer.swift
////  
////
////  Created by M K on 2022/05/13.
////

import Foundation
import Vision
import UIKit

public class BodyDrawer{
    
    //付け根部分のポイントの色
    let pointColor:CGColor = UIColor.green.cgColor
    //付け根部分のサイズ
    let ellipseSize:CGFloat = 2.0
    let boneLineWidth:CGFloat = 2.0
    
    /// ジョイント名はAppleサイトを確認
    /// https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images
    /// 検出させたいポイントを指定
    let detectionPoint: [VNHumanBodyPoseObservation.JointName] = [
        .leftAnkle,     //左足首
        .leftEar,       //左耳
        .leftElbow,     //左肘
        .leftEye,       //左目
        .leftHip,       //左尻
        .leftKnee,      //左膝
        .leftShoulder,  //左肩
        .leftWrist,     //左手首
        .neck,          //首
        .nose,          //鼻
        .rightAnkle,    //右足首
        .rightEar,      //右耳
        .rightElbow,    //右肘
        .rightEye,      //右目
        .rightHip,      //右尻
        .rightKnee,     //右膝
        .rightShoulder, //右肩
        .rightWrist,    //右手首
        .root           //ルート
    ]
    
    
    /// 骨格を描写する
    /// - Parameters:
    ///   - image: 描写対象のイメージ
    ///   - joints: 骨格情報
    /// - Returns:
    ///   - UIImage?: 描写後のイメージ
    func drawBody(image: UIImage,joints:[BodyJoint]) -> UIImage? {
        
        //Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(image.size)
        
        // Draw the starting image in the current context as background
        image.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        
        let radius = max(image.size.width, image.size.height) / 200
        
        
        // Draw joint
        for joint in joints {
            //検出するポイントか確認する
            if detectionPoint.contains(joint.name) {
                
                //parent(骨の描写)があれば、ラインを描く
                if let parentName = joint.parent.0{
                    if let parentPoint = getValueFromArray(name: parentName, source: joints){
                        
                        if parentPoint != CGPoint(x: 0, y: 0)
                        && joint.value != CGPoint(x: 0, y: 0){
                            
                            let lineColor:UIColor = joint.parent.1 ?? UIColor.white
                            context.setLineWidth(boneLineWidth)
                            context.setStrokeColor(lineColor.cgColor)
                            
                            context.move(to: CGPoint(x: joint.value.x, y: joint.value.y))
                            context.addLine(to: CGPoint(x: parentPoint.x, y: parentPoint.y))
                            context.strokePath()
                        }
                    }
                }
                
                //Joint部分に円を描く
                context.setStrokeColor(pointColor)
                context.setFillColor(pointColor)
                context.setAlpha(1)
                context.setLineWidth(ellipseSize)
                
                context.addArc(center: joint.value,
                               radius: radius,
                               startAngle: 0,
                               endAngle: .pi * 2,
                               clockwise: false)

                context.drawPath(using: .stroke) // or .fillStroke if need filling
            }
        }
        
        // Draw Angle
//        let angle = calcAngle(joints, position: position)
//        let text = String(round(angle*10)/10)//四捨五入
//        let font = UIFont.boldSystemFont(ofSize: 32)
//        let textRect  = CGRect(x: 60, y: 30, width: 100, height: 62)
//
//        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//        let textFontAttributes = [
//            NSAttributedString.Key.font: font,
//            NSAttributedString.Key.foregroundColor: UIColor.yellow,
//            NSAttributedString.Key.paragraphStyle: textStyle
//        ]
//        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        // Save the context as a new UIImage
        let drawImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        // Return modified image
        return drawImage
    }

    
    /// "source"の中にある"name"の値を取得する
    /// - Parameters:
    ///   - name: 座標情報がほしいジョイント名
    ///   - source: 骨格情報
    /// - Returns:
    ///   - CGPoint?: 座標情報
    func getValueFromArray(name:VNHumanBodyPoseObservation.JointName,
                        source:[BodyJoint])-> CGPoint? {
        for element in source {
            if element.name == name {
                return element.value
            }
        }
        return nil
    }
    
    
    /// ジョイント名で指定した座標を得る
    /// - Parameters:
    ///   - joints: ジョイントデータ
    ///   - jointName: 座標情報がほしいジョイント名
    /// - Returns: 座標
    func getJointPoint(_ joints:[BodyJoint], jointName: VNHumanBodyPoseObservation.JointName) -> CGPoint{
        for joint in joints {
            if joint.name == jointName{
                return joint.value
            }
        }
        return CGPoint(x: 0, y: 0)
    }
    
}
