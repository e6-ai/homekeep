import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Notification auth error: \(error)")
            }
        }
    }
    
    func scheduleReminder(for task: MaintenanceTask) {
        guard task.remindersEnabled, let nextDue = task.nextDue else { return }
        
        // Remove existing
        cancelReminder(for: task)
        
        let content = UNMutableNotificationContent()
        content.title = "HomeKeep Reminder"
        content.body = "\(task.name) is due\(task.reminderTiming == .dayOf ? " today" : " soon")."
        content.sound = .default
        content.badge = 1
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -task.reminderTiming.offsetDays, to: nextDue)!
        
        // Schedule at 9 AM on the reminder date
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder(for task: MaintenanceTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    func rescheduleAll(tasks: [MaintenanceTask]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for task in tasks where task.isEnabled {
            scheduleReminder(for: task)
        }
    }
}
