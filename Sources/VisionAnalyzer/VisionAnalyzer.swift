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
    ///   - callback: 分析した各ポイント
    public func analyze(cgImage:CGImage,callback: @escaping ([BodyJoint]) -> Void){
        analyzer.performRequests(cgImage: cgImage)
        callback(analyzer.points)
    }
    
    
    /// 骨格を検出する
    /// - Parameters:
    ///   - cgImage: 分析対象の画像
    ///   - callback: 分析結果の画像
    public func analyzedImage(cgImage:CGImage,callback: @escaping (CGImage?) -> Void){
        self.analyze(cgImage: cgImage, callback: { points in
            let points:[BodyJoint] = points
            guard let img = drawer.drawBody(image: UIImage(cgImage: cgImage), joints: points) else{
                return callback(nil)
            }
            callback(img.cgImage)
        })
    }
    
    
    /// 動画を画像に分割する
    /// - Parameter fileUrl: ビデオファイルのURL
    /// - Returns: 画像リスト
    public func movieSplit(fileUrl:URL) -> [CGImage]{
        let fileService:FileService = FileService()
        let imageArray:[CGImage] = fileService.convertVideoToImageArray(fileUrl: fileUrl)
        return imageArray
    }
    
}
