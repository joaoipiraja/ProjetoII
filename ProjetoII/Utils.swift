
import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func toHourFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let newDateString = dateFormatter.string(from: self)
        
        return newDateString
    }
}

extension TimeInterval {
    var seconds: Int {
        return Int(self) % 60
    }
}
