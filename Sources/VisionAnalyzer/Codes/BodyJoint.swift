import Foundation
import Vision
import UIKit

public struct BodyJoint {
    
    var name:VNHumanBodyPoseObservation.JointName
    var value:CGPoint
    
    ///NOTE:Parentは1:1だが、Childは1:Nなので、Parentを使う
    /// Rrturn - 親 と骨の色
    var parent:(VNHumanBodyPoseObservation.JointName?,UIColor?){
        var result:(VNHumanBodyPoseObservation.JointName?,UIColor?) = (nil,nil)
        
        switch self.name {
        case .nose:         //鼻
            // .neck - .nose
            result = (.neck,#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        case .rightEye:     //右目
            //.nose - .rightEye
            result = (.nose,#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        case .leftEye:      //左目
            //.nose - .leftEye
            result = (.nose,#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        case .rightEar:     //右耳
            //.rightEye - .rightEar
            result = (.rightEye,#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        case .leftEar:      //左耳
            // .leftEye - .leftEar
            result = (.leftEye,#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        
        case .neck:        //首
            //.root - .neck
            result = (.root,#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1))
        case .leftShoulder: //左肩
            // .neck - .leftShoulder
            result = (.neck,#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1))
        case .rightShoulder: //右肩
            // .neck - .rightShoulder
            result = (.neck,#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1))
        case .rightHip:     //右尻
            // .root - .rightHip
            result = (.root,#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1))
        case .leftHip:      //左尻
            // .root - .leftHip
            result = (.root,#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1))
            
        case .leftKnee:     //左膝
            // .lefttHip - .leftKnee
            result = (.leftHip,#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
        case .leftAnkle:  //左足首
            // .rightKnee - .rightAnkle
            result = (.leftKnee,#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
        case .rightElbow:   //右肘
            // .rightShoulder - .rightElbow
            result = (.rightShoulder,#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1))
        case .rightWrist:   //右手首
            // .rightElbow - .rightWrist
            result = (.rightElbow,#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1))
        
        case .rightKnee:    //右膝
            // .rightHip - .rightKnee
            result = (.rightHip,#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        case .rightAnkle:   //右足首
            // .rightKnee - .rightAnkle
            result = (.rightKnee,#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        case .leftElbow:    //左肘
            // .leftShoulder - .leftElbow
            result = (.leftShoulder,#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
        case .leftWrist: //左手首
            // .leftShoulder - .leftElbow
            result = (.leftElbow,#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
        case .root:
            result = (nil,nil)
        default:
            result = (nil,nil)
        }
        return result
    }
    
    
}
