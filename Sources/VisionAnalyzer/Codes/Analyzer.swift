//
//  Analyzer.swift
//  VisionAnalyzerDemo
//
//  Created by M K on 2022/05/13.
//

import Foundation
import Vision
import UIKit
import SwiftUI

//https://dev.classmethod.jp/articles/vision-body-pose/
public class Analyzer{

    ///座標から位置を特定するために画像のサイズを取得する
    private var width:CGFloat = CGFloat(0)
    private var height:CGFloat = CGFloat(0)
    
    ///骨
    public var points:[BodyJoint] = [BodyJoint]()
    
    ///胴体のジョイント名
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
    ]) {
        self.jointNames = jointNames
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
            let fixdPoint = Analyzer.flipUpsideDown(point: point.location,
                                        to: CGSize(width: width,height: height))

            return BodyJoint(name: name,value: fixdPoint)
        }
    }


    /// 座標系を反転する
    /// - Parameters:
    ///   - point: 現時点の座標
    ///   - size: 画像のサイズ
    /// ※ Reference
    /// 座標系、参考サイト
    /// https://nasubiblog.hatenablog.com/#%E5%BA%A7%E6%A8%99%E7%B3%BB
    static func flipUpsideDown(point: CGPoint, to size: CGSize) -> CGPoint {
        return CGPoint(x: point.x * size.width,
                       y: (1.0 - point.y) * size.height)
    }


    /// ２点間の距離：直交座標A(x,y)とB(x,y)の間の距離を求める関数
    /// - Parameters:
    ///   - start: 始点座標(x,y)
    ///   - end: 終点座標(x,y)
    static func getDistance(start: CGPoint, end: CGPoint) -> Int{
        let distance:Double = sqrt((end.x-start.x)*(end.x-start.x)+(end.y-start.y)*(end.y-start.y))
        return Int(distance)
    }

    /// ２点間の角度：ABの角度を求める関数
    /// - Parameters:
    ///   - origin: 始点座標(x,y)
    ///   - target: 終点座標(x,y)
    static func getRadian(origin: CGPoint, target: CGPoint) -> Double{
        let radian:Double = atan2(target.y - origin.y,target.x - origin.x);
        return radian
    }

    /// ラジアンから角度変換  (radians to degrees)
    /// - Parameters:
    ///   - radian: Double
    static func RadianToDegrees(radian:Double) -> Double{
        let degree = radian*180/Double.pi
        return degree
    }

    // 角度からラジアン変換  (degrees to radians)
    /// - Parameters:
    ///   - degrees: Double
    static func DegreesToRadian(degrees: Double) -> Double
    {
        let radian = degrees*Double.pi/180
        return radian
    }


    /// 3点のから角度を計算する
    /// ∠ABC を求める
    /// - Parameters:
    ///   - startPoint/A（始点）: CGPoint
    ///   - anglePoint/B（角度）: CGPoint
    ///   - endPoint/C（終点）: CGPoint
    static func threePointAngle(startPoint a: CGPoint, anglePoint b: CGPoint, endPoint c: CGPoint) -> Double{
        let angle = (atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x)) / Double.pi * 180
        return angle
    }

}
