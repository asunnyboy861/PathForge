# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "通知" / "提醒" → Push Notifications
- "同步" / "iCloud" → iCloud / CloudKit
- "购买" / "订阅" / "会员" / "premium" → In-App Purchase
- "Widget" / "主屏幕" → Widget Extension (no special entitlement)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | ✅ Configured | Xcode project |
| In-App Purchase | ✅ Configured | StoreKit 2 |
| iCloud / CloudKit | ✅ Configured | Xcode project |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| CloudKit Container | ⏳ Pending | 1. Open Xcode > Signing & Capabilities > Add iCloud 2. Check CloudKit 3. Create container: iCloud.com.zzoutuo.PathForge |
| App Store Connect IAP | ⏳ Pending | 1. Create subscription group in App Store Connect 2. Add monthly ($4.99) and yearly ($29.99) products |

## No Configuration Needed
- WidgetKit (no special entitlement required)
- UserNotifications (framework only, no capability)
- Swift Charts (framework only, no capability)
- StoreKit 2 (framework only, capability needed for App Store)

## Verification
- Build succeeded after configuration: ⏳ Pending
- All entitlements correct: ⏳ Pending
