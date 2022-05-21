import Foundation
import Vision
import SwiftUI


//https://dev.classmethod.jp/articles/vision-body-pose/
public struct VisionAnalyzer {
    
    //var analyzer:Analyzer = Analyzer()
    
    public var jointNames: [VNHumanBodyPoseObservation.JointName] = [
        .neck,
        .rightShoulder,
        .rightHip,
        .rightElbow,
        .rightWrist,
        .rightKnee,
        .rightAnkle,
        .root,
        .leftHip,
        .leftShoulder,
        .leftElbow,
        .leftWrist,
        .leftKnee,
        .leftAnkle,
        .nose,
        .rightEye,
        .rightEar,
        .leftEye,
        .leftEar
    ]

    public init(){
        
    }
    
   

    
}
