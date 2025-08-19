import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    @Published var isNotificationEnabled = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "daily_study_reminder"
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
            
            // 既存の通知をチェック
            let pendingRequests = await notificationCenter.pendingNotificationRequests()
            isNotificationEnabled = pendingRequests.contains { $0.identifier == notificationIdentifier }
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted
            return granted
        } catch {
            print("通知許可の取得に失敗: \(error)")
            return false
        }
    }
    
    func scheduleDailyNotification() async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        
        // 既存の通知を削除
        cancelDailyNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "中国語学習の時間です！"
        content.body = "今日も一緒に中国語を勉強しましょう 📚"
        content.sound = .default
        content.badge = 1
        
        // 毎日の通知を設定
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            isNotificationEnabled = true
            print("毎日の通知が設定されました: \(components.hour!):\(components.minute!)")
        } catch {
            print("通知の設定に失敗: \(error)")
        }
    }
    
    func cancelDailyNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        isNotificationEnabled = false
        print("毎日の通知がキャンセルされました")
    }
    
    func updateNotificationTime(_ newTime: Date) {
        notificationTime = newTime
        
        if isNotificationEnabled {
            Task {
                await scheduleDailyNotification()
            }
        }
    }
    
    func toggleNotification() {
        if isNotificationEnabled {
            cancelDailyNotification()
        } else {
            Task {
                await scheduleDailyNotification()
            }
        }
    }
}
