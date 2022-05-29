import Foundation
import Vision
import SwiftUI


//https://dev.classmethod.jp/articles/vision-body-pose/
public struct VisionAnalyzer {
    
    private var analyzer:Analyzer?
    
    public var jointNames: [VNHumanBodyPoseObservation.JointName]

    public init(jointNames: [VNHumanBodyPoseObservation.JointName] = [
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
    ]){
        self.jointNames = jointNames
        sefl.analyzer = Analyzer(jointNames: jointNames)
    }
    

    /// 3点のから角度を計算する
    /// ∠ABC を求める
    /// - Parameters:
    ///   - startPoint/A（始点）: CGPoint
    ///   - anglePoint/B（角度）: CGPoint
    ///   - endPoint/C（終点）: CGPoint
    public func threePointAngle(startPoint a: CGPoint, anglePoint b: CGPoint, endPoint c: CGPoint) -> Double{
        let angle = Analyzer.threePointAngle(startPoint: a, anglePoint: b, endPoint: c)
        return angle
    }
    
   
    
    ///ポイントを取得する
    func processObservation(_ observation: VNHumanBodyPoseObservation){

        // すべての胴体ポイントを取得
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return }

        self.points = jointNames.map { name in
            // confidence があるものだけ取得
             guard let point = recognizedPoints[name], point.confidence > 0 else {
                return BodyJoint(name: name,value: CGPoint(x: 0, y: 0))
             }
            
            // Vision の座標は[0~1]の範囲で表され、原点が左下（上下逆さ）なので、座標を再計算する
            let fixdPoint = Analyzer.flipUpsideDown(point: point.location,
                                        to: CGSize(width: width,height: height))

            return BodyJoint(name: name,value: fixdPoint)
        }
    }
    
}
