import Foundation
import AVFoundation
import SwiftUI


enum LocalDirectoryPath {
       
    case Home
    case Documents
    case Library
    case Caches
    case Tmp
    case ApplicationSupport
    
    func Path() -> String { // 普通はURLを使うこと
        switch self {
        case .Home:
            return NSHomeDirectory()
        case .Documents:
            return NSHomeDirectory() + "/Documents"
        case .Library:
            return NSHomeDirectory() + "/Library"
        case .Caches:
            return NSHomeDirectory() + "/Library/Caches"
        case .Tmp:
            return NSHomeDirectory() + "/tmp"
        case .ApplicationSupport:
            return NSHomeDirectory() + "/Library/Application Support"
        }
    }
    
    func URL() -> URL {
        switch self {
        case .Home:
            return Foundation.URL(string:NSHomeDirectory())!
        case .Documents:
            return Foundation.URL(string: NSHomeDirectory() + "/Documents")!
        case .Library:
            return Foundation.URL(string: NSHomeDirectory() + "/Library")!
        case .Caches:
            return Foundation.URL(string: NSHomeDirectory() + "/Library/Caches")!
        case .Tmp:
            return Foundation.URL(string: NSHomeDirectory() + "/tmp")!
        case .ApplicationSupport:
            return Foundation.URL(string: NSHomeDirectory() + "/Library/Application Support")!
        }
    }
}


/// /Documents/aigiaディレクトリ内の操作する
struct FileService {
    private static let app = "VisionAnalyzer"
    private let fileManager = FileManager.default
    private let rootDirectory = LocalDirectoryPath.Home.Path()+"/Documents/\(app)"

    init() {
        // ルートディレクトリを作成する
        createDirectory(atPath: "")
    }

    private func convertPath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return rootDirectory + path
        }
        return rootDirectory + "/" + path
    }

    /// ディレクトリを作成する
    /// - Parameter path: 対象パス
    func createDirectory(atPath path: String) {
        if fileExists(atPath: path) {
            return
        }
        do {
           try fileManager.createDirectory(atPath: convertPath(path), withIntermediateDirectories: false, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /// ファイルを作成する
    /// - Parameters:
    ///   - path: 保存先ファイルパス
    ///   - contents: コンテンツ
    func createFile(atPath path: String, contents: Data?) {
        // 同名ファイルがある場合は上書きされるので判定いるかも？
//        if fileExists(atPath: path) {
//            print("already exists file: \(NSString(string: path).lastPathComponent)")
//            return
//        }
        if !fileManager.createFile(atPath: convertPath(path), contents: contents, attributes: nil) {
            print("Create file error")
        }
    }

    /// ファイルがあるか確認する
    /// - Parameter path: 対象ファイルパス
    /// - Returns: ファイルがあるかどうか
    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: convertPath(path))
    }

    /// 対象パスがディレクトリか確認する
    /// - Parameter path: 対象パス
    /// - Returns:ディレクトリかどうか（存在しない場合もfalse）
    func isDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: convertPath(path), isDirectory: &isDirectory)
        return isDirectory.boolValue
    }

    /// ファイルを移動する
    /// - Parameters:
    ///   - srcPath: 移動元ファイルパス
    ///   - dstPath: 移動先ファイルパス
    func moveItem(atPath srcPath: String, toPath dstPath: String) {
        // 移動先に同名ファイルが存在する場合はエラー
        do {
           try fileManager.moveItem(atPath: convertPath(srcPath), toPath: convertPath(dstPath))
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /// ファイルをコピーする
    /// - Parameters:
    ///   - srcPath: コピー元ファイルパス
    ///   - dstPath: コピー先ファイルパス
    func copyItem(atPath srcPath: String, toPath dstPath: String) {
        // コピー先に同名ファイルが存在する場合はエラー
        do {
           try fileManager.copyItem(atPath: convertPath(srcPath), toPath: convertPath(dstPath))
        } catch let error {
            print(error.localizedDescription)
        }
    }
    

    func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

    /// ファイルを削除する
    /// - Parameter path: 対象ファイルパス
    func removeItem(atPath path: String) {
        do {
           try fileManager.removeItem(atPath: convertPath(path))
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /// ファイルをリネームする
    /// - Parameters:
    ///   - path: 対象ファイルパス
    ///   - newName: 変更後のファイル名
    func renameItem(atPath path: String, to newName: String) {
        let srcPath = path
        let dstPath = NSString(string: NSString(string: srcPath).deletingLastPathComponent).appendingPathComponent(newName)
        moveItem(atPath: srcPath, toPath: dstPath)
    }

    // ディレクトリ内のアイテムのパスを取得する
    /// - Parameter path: 対象ディレクトリパス
    /// - Returns:対象ディレクトリ内のアイテムのパス一覧
    func contentsOfDirectory(atPath path: String) -> [String] {
        do {
           return try fileManager.contentsOfDirectory(atPath: convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }

    /// ディレクトリ内のアイテムのパスを再帰的に取得する
    /// - Parameter path: 対象ディレクトリパス
    /// - Returns:対象ディレクトリ内のアイテムのパス一覧
    func subpathsOfDirectory(atPath path: String) -> [String] {
        do {
           return try fileManager.subpathsOfDirectory(atPath: convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }

    /// ファイル情報を取得する
    /// - Parameter path: 対象ファイルパス
    /// - Returns: 対象ファイルの情報（作成日など）
    func attributesOfItem(atPath path: String) -> [FileAttributeKey : Any] {
        do {
           return try fileManager.attributesOfItem(atPath: convertPath(path))
        } catch let error {
            print(error.localizedDescription)
            return [:]
        }
    }
    
    /// tmp ディレクトリを全て削除する
    func clearTmpDirectory(){
        var removed: Int = 0
        do {
            let tmpDirURL = URL(string: NSTemporaryDirectory())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print("\(tmpFiles.count) temporary files found")
            for url in tmpFiles {
                removed += 1
                try FileManager.default.removeItem(at: url)
            }
            print("\(removed) temporary files removed")
        } catch {
            print(error)
            print("\(removed) temporary files removed")
        }
    }

    
    func jpegExportOne(image:UIImage) {
//        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            fatalError("フォルダURL取得エラー")
//        }
        let dirURL = URL(fileURLWithPath: rootDirectory)
        
        let failename = "\(Date().timestamp).jpeg"
        let imageURL = dirURL.appendingPathComponent(failename)
        
        let data = image.jpegData(compressionQuality: 1.0)
        do {
            try data?.write(to: imageURL)
            print(failename)
        } catch let error {
            print(error)
        }
    }
    
    /// 動画をフレーム毎の画像に切り分ける
    /// - Parameters:
    ///   - fileUrl: 動画が配置されている場所のURL
    /// - Returns: フレーム毎に分けられた画像配列
    /// - Reference:   https://aminaura.hatenablog.com/entry/2016/05/03/065550
    func convertVideoToImageArray(fileUrl:URL) -> [CGImage] {
        
        let asset = AVAsset(url: fileUrl)
        
        var images = [CGImage]()
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return [CGImage]() }

        var reader: AVAssetReader?
        do {
            reader = try AVAssetReader(asset: asset)
        } catch let error as NSError {
            print(error)
        }

        let options = [
            "\(kCVPixelBufferPixelFormatTypeKey)": Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: options)
        reader?.add(output)
        reader?.startReading()

        while let sample = output.copyNextSampleBuffer() {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sample) else { return [CGImage]() }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
            images.append(cgImage!)
        }

        return images
    }
    
    
}

// USAGE
//let hoge = FileService()
//hoge.createDirectory(atPath: "fuga")
//hoge.createDirectory(atPath: "fuga/foo")
//print(hoge.isDirectory(atPath: "fuga")) // true
//hoge.createFile(atPath: "fuga/piyo.txt", contents: "あいうえお".data(using: .utf8))
//hoge.copyItem(atPath: "fuga/piyo.txt", toPath: "fuga/piyoコピー.txt")
//hoge.copyItem(atPath: "fuga/piyo.txt", toPath: "fuga/piyoコピー2.txt")
//hoge.moveItem(atPath: "fuga/piyo.txt", toPath: "fuga/foo/piyo.txt")
//hoge.removeItem(atPath: "fuga/piyoコピー2.txt")
//hoge.renameItem(atPath: "fuga/piyoコピー.txt", to: "コピーです.txt")
//print(hoge.contentsOfDirectory(atPath: "")) // ["fuga"]
//print(hoge.subpathsOfDirectory(atPath: "")) // ["fuga", "fuga/コピーです.txt", "fuga/foo", "fuga/foo/piyo.txt"]
//let attributes = hoge.attributesOfItem(atPath: "fuga/コピーです.txt")
