
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
    
        func adding(seconds: Int) -> Date {
            return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
        }
    
}

extension TimeInterval {
    var seconds: Int {
        return Int(self) % 60
    }
}
