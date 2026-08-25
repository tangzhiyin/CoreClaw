import Contacts
import EventKit

/// 共享系统 store 单例，供所有 ToolHandler 和 AppPermissions 使用。
/// 解耦 ToolRegistry，避免重复实例。
enum SystemStores {
    static let event = EKEventStore()
    static let contacts = CNContactStore()
}
