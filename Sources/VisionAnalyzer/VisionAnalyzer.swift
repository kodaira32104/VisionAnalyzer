import Foundation
import Vision
import SwiftUI


//https://dev.classmethod.jp/articles/vision-body-pose/
public struct VisionAnalyzer {
    
    private var analyzer:Analyzer = Analyzer()
    private let drawer:BodyDrawer = BodyDrawer()

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
        self.analyzer = Analyzer(jointNames: jointNames)
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
    
   
    /// 骨格を検出する
    /// - Parameters:
    ///   - cgImage: 分析対象の画像
    /// - Returns: 分析した各ポイント
    public func analyze(cgImage:CGImage) -> [BodyJoint]{
        analyzer.performRequests(cgImage: cgImage)
        return  analyzer.points
    }
    
    /// 骨格を検出する
    /// - Parameters:
    ///   - cgImage: 分析対象の画像
    /// - Returns: 分析結果の画像
    public func analyzedImage(cgImage:CGImage) -> CGImage?{
        
        let points:[BodyJoint] = self.analyze(cgImage: cgImage)
        
        guard let img = drawer.drawBody(image: UIImage(cgImage: cgImage), joints: points) else{
            return nil
        }
        
        return img.cgImage
    }
    
}
