import Foundation
//NOTE
//SwiftのDateはGMT(UTC)ベースなので日本では９時間ズレる
//また、実機やシミュレーターの地域などによっても表示時間が変わる可能性があるので注意する

///Date型の拡張クラス
///日付の計算などを拡張
public extension Date {
    
    ///拡張した初期化処理、文字列で受け取った値をDate型で保持する
    init?(dateString: String, dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ") {
        guard let date = Date.defaultFormatter.date(from: dateString) else { return nil }
        self = date
    }
    
    ///日時フォーマット
    ///NOTE: 日本での利用が前提なのでタイムゾーンを日本に指定する
    static var defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        return formatter
    }()
    
    ///UTC(協定世界時) 時間で取得
    var UTC: Date {
        get { return self }
    }

    ///JST(日本標準時): UTC+9時間で取得
    var JST: Date {
        get {
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(byAdding: .hour, value: 9, to: self)!
        }
    }
    
    ///ログ出力時のタイムスタンプとして利用
    var timestamp : String{
        get {
            return Date.defaultFormatter.string(from: self)
        }
    }

    /// JST(日本標準時)で受け取った時間をUTC(協定世界時)で返す
    /// - Parameter jst: JST時間
    /// - Returns: UTC時間
    static func ConvertJSTtoUTC(jst:Date)->Date{
        return Calendar.current.date(byAdding: .hour, value: -9, to: jst)!
    }
    
    
    /// UTC(協定世界時)で受け取った時間をJST(日本標準時)で返す
    /// - Parameter utc: UTC時間
    /// - Returns: JST時間
    static func ConvertUTCtoJST(utc:Date)->Date{
        return Calendar.current.date(byAdding: .hour, value: 9, to: utc)!
    }
    
    
    /// 指定した日時に設定する
    /// - Parameters:
    ///   - year:[オプション]年を指定する場合
    ///   - month:[オプション]月を指定する場合
    ///   - day:[オプション]日を指定する場合
    ///   - hour:[オプション]時を指定する場合
    ///   - minute:[オプション]分を指定する場合
    ///   - second:[オプション]秒を指定する場合
    /// - Returns: 変更された日時
    func setDateTime(year:Int? = nil, month:Int? = nil, day:Int? = nil,
                     hour:Int? = nil, minute:Int? = nil, second:Int? = nil)->Date{

        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        if year     != nil{ components.year = year }
        if month    != nil{ components.month = month }
        if day      != nil{ components.day = day }
        if hour     != nil{ components.hour = hour }
        if minute   != nil{ components.minute = minute }
        if second   != nil{ components.second = second }
    
        return calendar.date(from: components)!
    }
  
    
    // https://qiita.com/jpmartha/items/4edf5ca2e40f3a4c18ce
    /// ISO8601文字列をDateに変換する
    /// - Parameter iso8601string: ISO8601文字列
    /// - Returns: Date型の日時
    static func ConvertISO8601StringToDate(iso8601string:String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let date:Date = formatter.date(from: iso8601string)!
        //変換時に9時間のズレが生じるので修正する
        let convertDate:Date = Calendar.current.date(byAdding: .hour, value: -9, to: date)!
        return convertDate
    }
    
    /// DateをISO8601文字列に変換する
    /// - Parameter date: Date型の日時
    /// - Returns: 文字列型の日時
    static func ConvertDateToISO8601String(date:Date) -> String {
        let formatter = ISO8601DateFormatter()
        let str:String = formatter.string(from: date)
        return str
    }
    
    /// 文字列型の日付を返す
    /// - Parameter format: [オプション]指定のフォーマットがある場合
    /// - Returns: 文字列型の日付
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "GMT")//TimeZone.current
        formatter.locale = Locale(identifier: "en_US")//Locale.current
        return formatter.string(from: self)
    }
    
    /// 文字列型の日付をDate型にして返す
    /// - Parameters:
    ///   - string: 文字列型の日付
    ///   - format: [オプション]指定のフォーマットがある場合
    /// - Returns: 日付
    static func toDate(string: String, format:String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "GMT")//TimeZone.current
        formatter.locale = Locale(identifier: "en_US")//Locale.current

        guard let date = formatter.date(from: string) else {
            return nil
        }
        return date
    }

    
    /// 日付だけ取得する
    /// - Returns: ex. 1/23
    func dateOnly() -> String {
        let formatter = Date.defaultFormatter
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return (formatter.string(from: self))
    }
    
    /// 時間だけ取得する
    /// - Returns: ex. 12:34
    func timeOnly() -> String {
        let formatter = Date.defaultFormatter
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return (formatter.string(from: self))
    }
    
    /**
    　　本日を書式指定して文字列で取得
        // ex.
        print(getToday()) // 2016/11/28 14:41:07
        print(getToday(format:"yyyy-MM-dd")) // 2016-11-28
     - parameter format: 書式（オプション）。未指定時は"yyyy/MM/dd HH:mm:ss"
     - returns: 本日の日付
    */
    static func getToday(format:String = "yyyy/MM/dd HH:mm:ss") -> String {
        let now = Date()
        let formatter = Date.defaultFormatter
        formatter.dateFormat = format
        return formatter.string(from: now as Date)
    }
    
    /**
    　　２つの日付の差(n日)を取得
        // ex. ２つの日付の差
        print(getIntervalDays(date: date1,anotherDay: date2))
        // ex. 本日との差
        print(getIntervalDays(date: date1))
     - parameter date: 日付
     - parameter anotherDay: 日付（オプション）。未指定時は当日が適用される
     - returns: 算出後の日付
    */
    static func getIntervalDays(date:Date?,anotherDay:Date? = nil) -> Double {
        var retInterval:Double!
        if anotherDay == nil {
            retInterval = date?.timeIntervalSinceNow
        } else {
            retInterval = date?.timeIntervalSince(anotherDay!)
        }
        let ret = retInterval/86400
        return floor(ret)  // n日
    }

    /// 年の増減
    static func calcDateYear(year:Int,baseDate:String? = nil) -> Date {
        return calcDate(year:year,month:0,day:0,hour:0,minute:0,second:0,baseDate: baseDate)
    }

    /// 月の増減
    static func calcDateMonth(month:Int,baseDate:String? = nil) -> Date {
        return calcDate(year:0,month:month,day:0,hour:0,minute:0,second:0,baseDate: baseDate)
    }

    /// 日の増減
    static func calcDateDay(day:Int,baseDate:String? = nil) -> Date {
        return calcDate(year:0,month:0,day:day,hour:0,minute:0,second:0,baseDate: baseDate)
    }

    /**
     日付の計算
     - parameter year: 年の増減値。マイナス指定可能
     - parameter month: 月の増減値。マイナス指定可能
     - parameter day: 日の増減値。マイナス指定可能
     - parameter hour: 時の増減値。マイナス指定可能
     - parameter minute: 分の増減値。マイナス指定可能
     - parameter second: 秒の増減値。マイナス指定可能
     - parameter baseDate: 基準日（オプション）。指定した場合はこの日付を基準にする
     - returns: 計算結果の日付
     */
    static func calcDate(year:Int ,month:Int ,day:Int ,hour:Int ,minute:Int ,second:Int ,baseDate:String? = nil) -> Date {

        let formatter = Date.defaultFormatter

        var components = DateComponents()
        components.setValue(year,for: Calendar.Component.year)
        components.setValue(month,for: Calendar.Component.month)
        components.setValue(day,for: Calendar.Component.day)
        components.setValue(hour,for: Calendar.Component.hour)
        components.setValue(minute,for: Calendar.Component.minute)
        components.setValue(second,for: Calendar.Component.second)

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let base:Date?

        if let _ = baseDate {
            if let _ = formatter.date(from: baseDate!) {
                base = formatter.date(from: baseDate!)!
            } else {
                print("baseDateの日付変換に失敗したため、本日の日付を使用します")
                base = Date()
            }
        } else {
            base = Date()
        }
        return calendar.date(byAdding: components, to: base!)!
    }
    
    
}

// USAGE
//Date().toString(format: "yyyy/MM/dd") // 2017/02/26
//Date(dateString: "2016-02-26T10:17:30Z")  // Date
