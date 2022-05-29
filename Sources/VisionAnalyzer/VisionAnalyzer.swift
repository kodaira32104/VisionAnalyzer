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
    
   
    
    /// 骨格を検出する
    /// - Parameters:
    ///   - cgImage: 分析対象の画像
    public func performRequests(cgImage:CGImage){

        //反復する際にログが残るので関数呼び出し時に消す
        self.points = []

        let uiImage:UIImage = UIImage(cgImage: cgImage)
        self.width = uiImage.size.width
        self.height = uiImage.size.height

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }

    /// 結果を処理する
    /// - Parameters:
    ///   - request: 分析要求の抽象クラス
    ///   - error: エラー
    func bodyPoseHandler(request: VNRequest, error: Error?) {

        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            return
        }

        // Process each observation to find the recognized body pose points.
        observations.forEach {
            processObservation($0)
        }
    }


    ///ポイントを取得する
    func processObservation(_ observation: VNHumanBodyPoseObservation){

        // すべての胴体ポイントを取得します
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return}

        self.points = jointNames.map { name in
            // confidence があるものだけ取得
             guard let point = recognizedPoints[name], point.confidence > 0 else {
                return BodyJoint(name: name,value: CGPoint(x: 0, y: 0))
             }

            /// ポイントを正規化された座標から画像の座標に変換
            /// 公式では、下記の例が記載されているが座標系に誤差が生じるため使用していない
            /// let normalizedPoint = VNImagePointForNormalizedPoint(point.location,Int(width),Int(height))

            // Vision の座標は[0~1]の範囲で表され、原点が左下（上下逆さ）なので、座標を再計算する
            let fixdPoint = self.flipUpsideDown(point: point.location,
                                        to: CGSize(width: width,height: height))

            return BodyJoint(name: name,value: fixdPoint)
        }
    }
    
}
