import Foundation
import Vision
import UIKit
import SwiftUI

public struct VisionAnalyzer {
    
    var analyzer:Analyzer = Analyzer()

    public init(){
        
    
    }
    
    public analyze(cgImage:CGImage) ->CGImage?{
        
        analyzer.performRequests(cgImage: cgImage)
        let points:[BodyJoint] = analyzer.points
        
        //画面を書き変えるためにmainQueueで処理する
        DispatchQueue.main.sync {
            guard let img = drawer.drawBody(image: UIImage(cgImage: cgImage), joints: points) else{
                return nil
            }
            return img
        }
    }
    
   
    public hoge(text:String)->String{
        return "piyo"
    }

    
    
}
