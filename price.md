# Pricing Configuration

## Monetization Model: Subscription (IAP) — BYOK (Bring Your Own Key)

## Core Principle
Users provide their own API key (OpenAI, DeepSeek, Ollama, etc.) and pay their own API costs directly. The developer has zero marginal cost for AI usage. Therefore, IAP does NOT limit AI usage — it unlocks premium app features that require ongoing development investment.

## Subscription Group
- **Group Name**: PathForge Premium
- **Group ID**: com.zzoutuo.PathForge.premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.PathForge.pro.monthly`
- **Price**: $2.99 per month
- **Display Name**: Monthly Premium
- **Description**: Unlock all Pro features with monthly billing
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.PathForge.pro.yearly`
- **Price**: $14.99 per year (Save 58% vs monthly)
- **Display Name**: Yearly Premium
- **Description**: Unlock all Pro features with yearly billing
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.PathForge.pro.lifetime`
- **Price**: $29.99 one-time
- **Display Name**: Lifetime Access
- **Description**: Unlock all Pro features forever, one-time purchase
- **Localization**: English (US)
- **Note**: Non-consumable IAP for users who want permanent access

## Free Tier (No IAP Required)
- Unlimited learning paths (user provides own API key)
- Unlimited AI path generation (user pays own API costs)
- Unlimited AI path adjustment (user pays own API costs)
- Daily task tracking
- Basic progress view
- System notification reminders
- Demo mode (sample data, no API key needed)

## Pro Features (Unlocked with any purchase)
- Detailed learning statistics (charts + trends)
- Export learning reports (PDF)
- Custom widget styles
- Saved AI configuration profiles (unlimited)
- iCloud sync across devices
- Priority support

## Demo Mode (For App Review & First-time Users)
- Works without any API key
- Pre-loaded sample learning path with milestones and tasks
- Full task interaction (check off, view details)
- Allows Apple reviewers to test all non-AI features
- Clear banner indicating "Demo Mode — Add your API key in Settings for AI features"

## App Review Notes Template
```
IMPORTANT — DEMO API KEY PROVIDED:
This app uses a BYOK (Bring Your Own Key) model. We provide a demo API key below for testing. See app_review_info.md for full details.

DEMO API KEY (for App Review testing):
- API Key: sk-demo-review-2026-pathforge-test-key
- Base URL: https://api.openai.com/v1/chat/completions
- Model ID: gpt-4o-mini

HOW TO TEST THE APP:
1. Launch the app — a demo learning path ("Master SwiftUI Development") is automatically pre-loaded
2. You can explore all features: view tasks, check off completed items, view milestones, see progress
3. To test AI features: Navigate Settings > AI Configuration > enter the demo API key above > Test Connection
4. Then use "Create Path" to generate a new learning path with AI
5. Or open the demo path and tap "Adjust Path with AI"

ABOUT IN-APP PURCHASES:
- IAP products may not load in sandbox/test environments. This is expected behavior.
- In production (App Store), subscriptions will load and function normally.
- The app is fully functional without IAP — all AI features work with a user-provided API key.
- Pro subscription unlocks: Detailed Statistics, Export Reports, Custom Widgets, Saved AI Profiles, iCloud Sync, Priority Support.
- Please ensure the Paid Apps Agreement is active in App Store Connect > Business.

IAP Product IDs for reference:
- com.zzoutuo.PathForge.pro.monthly ($2.99/month)
- com.zzoutuo.PathForge.pro.yearly ($14.99/year)
- com.zzoutuo.PathForge.pro.lifetime ($29.99 one-time)
```

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms
- [x] Cancellation instructions included
- [x] Pricing clearly stated
- [x] Restore purchases functionality implemented
- [x] Free tier provides real value (not just a teaser)
- [x] No usage limits on BYOK features
