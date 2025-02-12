import Foundation

struct DateHelper {
    static func extractTime(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"
            return outputFormatter.string(from: date)
        }
        return ""
    }
    
    static func getTimeWithOffset(localTime: String) -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current
        
        let currentTimeString = formatter.string(from: now)
        var diff = 0
        
        if let first = extractHour(from: localTime),
           let second = extractHour(from: currentTimeString) {
            diff = first - second
        }
        
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .hour, value: diff, to: now) {

            return formatter.string(from: newDate)
        }
        return "Ошибка"
    }
    
    static func extractHour(from timeString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let date = formatter.date(from: timeString) {
            let calendar = Calendar.current
            return calendar.component(.hour, from: date)
        }
        return nil
    }
}
