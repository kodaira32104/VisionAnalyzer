import AVFoundation
import UIKit
import SwiftUI

class MovieService {
    
    //保存先のURL
    var url:URL?
    
    //フレーム数
    var frameCount = 0
    
    // FPS
    let fps: __int32_t = 60
    var time:Int = 60    // (time / fps)   VCからいじる
    
    var videoWriter:AVAssetWriter?
    var writerInput:AVAssetWriterInput?
    var adaptor:AVAssetWriterInputPixelBufferAdaptor!
    
    private let FILENAME:String = "vision_select.mp4"
    
    //適当に画像サイズ
    var imageSize = CGSize(width:1280,height:960)
    init(imageSize:CGSize = CGSize(width:1280,height:960)){
        self.imageSize = imageSize
    }
    
    /// 画像から動画を作成する（一番最初はコレを呼び出す）
    /// - Parameters:
    ///   - image: 動画にするための画像
    ///   - size: 画像のサイズ
    func createFirst(image:UIImage,size:CGSize){
        
        //保存先のURL
        url = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).mp4")
        // AVAssetWriter
        guard let firstVideoWriter = try? AVAssetWriter(outputURL: url!, fileType: AVFileType.mov) else {
            fatalError("AVAssetWriter error")
        }
        videoWriter = firstVideoWriter
        
        //画像サイズ
        let width = size.width
        let height = size.height
        
        // AVAssetWriterInput
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ] as [String : Any]
        writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings as [String : AnyObject])
        videoWriter!.add(writerInput!)
        
        // AVAssetWriterInputPixelBufferAdaptor
        adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput!,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                ]
        )
        
        writerInput?.expectsMediaDataInRealTime = true
        
        // 動画の生成開始
        
        // 生成できるか確認
        if (!videoWriter!.startWriting()) {
            // error
            print("error videoWriter startWriting")
        }
        
        // 動画生成開始
        videoWriter!.startSession(atSourceTime: CMTime.zero)
        
        // pixel bufferを宣言
        var buffer: CVPixelBuffer? = nil
        
        // 現在のフレームカウント
        frameCount = 0
        
        if (!adaptor.assetWriterInput.isReadyForMoreMediaData) {
            return
        }
        
        // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
        let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(time)), timescale: fps)
        //時間経過を確認(確認用)
        let second = CMTimeGetSeconds(frameTime)
        print(second)
        
        // CGImageからBufferを生成
        buffer = self.pixelBufferFromCGImage(cgImage: image.cgImage!)
        
        // 生成したBufferを追加
        if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
            // Error!
            print("adaptError")
            print(videoWriter!.error!)
        }
        frameCount += 1
    }
    
    
    /// 画像から動画を作成する（２回め以降はこれを呼び出す）
    /// - Parameters:
    ///   - image: 動画にするための画像

    func createSecond(image:UIImage){
        //videoWriterがなければ終了
        if videoWriter == nil{
            return
        }
        
        // pixel bufferを宣言
        var buffer: CVPixelBuffer? = nil
        
        if (!adaptor.assetWriterInput.isReadyForMoreMediaData) {
            return
        }
        
        // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
        let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(time)), timescale: fps)
        //時間経過を確認(確認用)
        let second = CMTimeGetSeconds(frameTime)
        print(second)
        
        // CGImageからBufferを生成
        buffer = self.pixelBufferFromCGImage(cgImage: image.cgImage!)
        
        // 生成したBufferを追加
        if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
            // Error!
            print(videoWriter!.error!)
        }
        
        print("frameCount :\(frameCount)")
        frameCount += 1
    }
    
    ///終わったら後始末をしてURLを返す
    func finished(_ completion:@escaping (URL)->()){
        // 動画生成終了
        if writerInput == nil || videoWriter == nil{
            return
        }
        writerInput!.markAsFinished()
        videoWriter!.endSession(atSourceTime: CMTimeMake(value: Int64((__int32_t(frameCount)) *  __int32_t(time)), timescale: fps))
        videoWriter!.finishWriting(completionHandler: {
            // Finish!
            print("movie created.")
            self.writerInput = nil
            self.videoWriter = nil
            if self.url != nil {
                completion(self.url!)
            }
        })
    }
    
    ///ピクセルバッファへの変換
    func pixelBufferFromCGImage(cgImage: CGImage) -> CVPixelBuffer {
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pxBuffer: CVPixelBuffer? = nil
        
        let width = cgImage.width
        let height = cgImage.height
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32ARGB,
                            options as CFDictionary?,
                            &pxBuffer)
        
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pxdata = CVPixelBufferGetBaseAddress(pxBuffer!)
        
        let bitsPerComponent: size_t = 8
        let bytesPerRow: size_t = 4 * width
        
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x:0, y:0, width:CGFloat(width),height:CGFloat(height)))
        
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pxBuffer!
    }
    
    
    static func movieSplit(fileUrl:URL) -> [CGImage]{
        let fileService:FileService = FileService()
        let imageArray:[CGImage] = fileService.convertVideoToImageArray(fileUrl: fileUrl)
        return imageArray
    }
    
    
    
}
