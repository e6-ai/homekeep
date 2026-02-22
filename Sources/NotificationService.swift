import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private enum SettingsKey {
        static let globalReminders = "globalReminders"
        static let reminderHour = "reminderHour"
    }
    
    private init() {}
    
    var globalRemindersEnabled: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: SettingsKey.globalReminders) != nil else { return true }
        return defaults.bool(forKey: SettingsKey.globalReminders)
    }

    private var reminderHour: Int {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: SettingsKey.reminderHour) != nil else { return 9 }
        let hour = defaults.integer(forKey: SettingsKey.reminderHour)
        return (6...21).contains(hour) ? hour : 9
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    print("Notification auth error: \(error)")
                }
                continuation.resume(returning: granted)
            }
        }
    }

    func checkAuthorizationStatus() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral, .notDetermined:
                    continuation.resume(returning: true)
                case .denied:
                    continuation.resume(returning: false)
                @unknown default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func scheduleReminder(for task: MaintenanceTask) {
        cancelReminder(for: task)

        guard globalRemindersEnabled,
              task.isEnabled,
              task.remindersEnabled,
              let nextDue = task.nextDue else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "HomeKeep Reminder"
        content.body = reminderBody(for: task)
        content.sound = .default
        content.badge = 1

        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -task.reminderTiming.offsetDays, to: nextDue) else {
            return
        }

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = reminderHour
        dateComponents.minute = 0

        guard let scheduledDate = calendar.date(from: dateComponents), scheduledDate > Date() else {
            return
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder(for task: MaintenanceTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    func rescheduleAll(tasks: [MaintenanceTask]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard globalRemindersEnabled else { return }

        for task in tasks {
            scheduleReminder(for: task)
        }
    }

    private func reminderBody(for task: MaintenanceTask) -> String {
        switch task.reminderTiming {
        case .dayOf:
            return "\(task.name) is due today."
        case .dayBefore:
            return "\(task.name) is due tomorrow."
        case .weekBefore:
            return "\(task.name) is due in one week."
        }
    }
}
