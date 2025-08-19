import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: ModernDesignSystem.Spacing.lg) {
                // ヘッダー説明
                headerSection
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                
                // 通知設定セクション
                notificationToggleSection
                    .padding(.horizontal, ModernDesignSystem.Spacing.md)
                
                // 時間設定セクション
                if notificationManager.isNotificationEnabled {
                    timePickerSection
                        .padding(.horizontal, ModernDesignSystem.Spacing.md)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
            }
            .animation(.easeInOut(duration: 0.3), value: notificationManager.isNotificationEnabled)
            .navigationTitle("通知設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .foregroundColor(ModernDesignSystem.Colors.accent)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(ModernDesignSystem.Colors.accent)
            
            VStack(spacing: ModernDesignSystem.Spacing.xs) {
                Text("学習リマインダー")
                    .font(ModernDesignSystem.Typography.headlineMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(ModernDesignSystem.Colors.text)
                
                Text("毎日決まった時間に学習を促す通知を受け取ることができます")
                    .font(ModernDesignSystem.Typography.bodyMedium)
                    .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, ModernDesignSystem.Spacing.lg)
    }
    
    private var notificationToggleSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    Text("毎日のリマインダー")
                        .font(ModernDesignSystem.Typography.titleMedium)
                        .foregroundColor(ModernDesignSystem.Colors.text)
                    
                    Text("学習習慣を身につけましょう")
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { notificationManager.isNotificationEnabled },
                    set: { _ in notificationManager.toggleNotification() }
                ))
                .toggleStyle(SwitchToggleStyle(tint: ModernDesignSystem.Colors.accent))
            }
            
            if !notificationManager.isAuthorized && notificationManager.isNotificationEnabled {
                HStack(spacing: ModernDesignSystem.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    
                    Text("設定アプリで通知を許可してください")
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
                .padding(ModernDesignSystem.Spacing.sm)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(ModernDesignSystem.CornerRadius.sm)
            }
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(Color.white)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
    
    private var timePickerSection: some View {
        VStack(spacing: ModernDesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: ModernDesignSystem.Spacing.xs) {
                    Text("通知時間")
                        .font(ModernDesignSystem.Typography.titleMedium)
                        .foregroundColor(ModernDesignSystem.Colors.text)
                    
                    Text("毎日この時間に通知が届きます")
                        .font(ModernDesignSystem.Typography.bodySmall)
                        .foregroundColor(ModernDesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
            
            DatePicker(
                "通知時間",
                selection: Binding(
                    get: { notificationManager.notificationTime },
                    set: { notificationManager.updateNotificationTime($0) }
                ),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxHeight: 120)
        }
        .padding(ModernDesignSystem.Spacing.md)
        .background(Color.white)
        .cornerRadius(ModernDesignSystem.CornerRadius.md)
        .shadow(
            color: ModernDesignSystem.Shadow.subtle.color,
            radius: ModernDesignSystem.Shadow.subtle.radius,
            x: ModernDesignSystem.Shadow.subtle.x,
            y: ModernDesignSystem.Shadow.subtle.y
        )
    }
}

#Preview {
    NotificationSettingsView()
}
