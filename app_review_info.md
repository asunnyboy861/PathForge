# App Review Information

## App Name
PathForge

## Bundle ID
com.zzoutuo.PathForge

## Version
1.0 (11)

## Demo API Key (For App Review Testing)

This app uses a BYOK (Bring Your Own Key) model. A demo API key is provided below for testing purposes.

- **API Key**: `sk-demo-review-2026-pathforge-test-key`
- **Base URL**: `https://api.openai.com/v1/chat/completions`
- **Model ID**: `gpt-4o-mini`

## How to Test

### Step 1: Launch the App
- A demo learning path ("Master SwiftUI Development") is automatically pre-loaded
- You can explore all features: view tasks, check off completed items, view milestones, see progress

### Step 2: Test AI Features (Optional)
1. Navigate to **Settings > AI Configuration**
2. Enter the demo API key: `sk-demo-review-2026-pathforge-test-key`
3. Keep the default Base URL and Model ID
4. Tap **Test Connection** to verify
5. Use **Create Path** to generate a new learning path with AI

### Step 3: Test Path Adjustment
1. Open the demo learning path
2. Scroll to the bottom and tap **Adjust Path with AI**
3. Enter feedback (e.g., "Add more hands-on projects")
4. Tap **Adjust Path**

## In-App Purchase Information

### Product IDs
- `com.zzoutuo.PathForge.pro.monthly` — Monthly Premium ($2.99/month, auto-renewable)
- `com.zzoutuo.PathForge.pro.yearly` — Yearly Premium ($14.99/year, auto-renewable)
- `com.zzoutuo.PathForge.pro.lifetime` — Lifetime Access ($29.99, non-consumable)

### IAP Notes
- IAP products may not load in sandbox/test environments. This is expected behavior.
- In production (App Store), subscriptions will load and function normally.
- The app is fully functional without IAP — all AI features work with a user-provided API key.
- Pro subscription unlocks: Detailed Statistics, Export Reports, Custom Widgets, Saved AI Profiles, iCloud Sync, Priority Support.
- Please ensure the Paid Apps Agreement is active in App Store Connect > Business.

### Subscription Management
- Restore Purchases button is available in Settings > Subscription
- Subscription details and cancellation instructions are shown in the Paywall view
- Manage subscriptions link: https://apps.apple.com/account/subscriptions

## Policy Pages

- **Support**: https://asunnyboy861.github.io/PathForge/support.html
- **Privacy Policy**: https://asunnyboy861.github.io/PathForge/privacy.html
- **Terms of Use (EULA)**: https://asunnyboy861.github.io/PathForge/terms.html

## Demo Mode

When no API key is configured, the app operates in Demo Mode:
- A pre-loaded sample learning path is available
- All non-AI features work (task management, progress tracking, notifications)
- A banner indicates "Demo Mode — Add your API key in Settings for AI features"
- Demo data is automatically removed when the user adds their own API key
