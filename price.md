# Pricing Configuration

## Monetization Model: Lifetime Purchase (Primary) + Subscription (Optional)

## Core Insight
PathForge uses user-provided API keys, meaning **zero API cost for the developer**.
The app is a pure local tool with SwiftData storage.
Therefore, a **lifetime purchase model** is the most user-friendly and profitable approach.

## Product IDs (Non-Consumable IAP)

### 1. Lifetime Purchase (Recommended)
- **Reference Name**: PathForge Pro Lifetime
- **Product ID**: `com.zzoutuo.PathForge.pro.lifetime`
- **Price**: $9.99 (one-time)
- **Display Name**: PathForge Pro
- **Description**: Unlock all Pro features forever. One-time purchase, no subscriptions.
- **Localization**: English (US)
- **IAP Type**: Non-Consumable

### 2. Monthly Subscription (Optional)
- **Reference Name**: PathForge Pro Monthly
- **Product ID**: `com.zzoutuo.PathForge.pro.monthly`
- **Price**: $2.99 per month
- **Display Name**: Monthly Plan
- **Description**: Full access to all Pro features. Cancel anytime.
- **Localization**: English (US)
- **IAP Type**: Auto-Renewable Subscription

### 3. Yearly Subscription (Optional)
- **Reference Name**: PathForge Pro Yearly
- **Product ID**: `com.zzoutuo.PathForge.pro.yearly`
- **Price**: $14.99 per year (~$1.25/month)
- **Display Name**: Yearly Plan
- **Description**: Best value subscription. Save 50% vs monthly.
- **Localization**: English (US)
- **IAP Type**: Auto-Renewable Subscription

## Pricing Strategy Rationale

| Plan | Price | Positioning |
|------|-------|-------------|
| Lifetime | $9.99 | **Recommended** - Best value, no recurring cost |
| Monthly | $2.99/mo | Low barrier to try Pro features |
| Yearly | $14.99/yr | For users who prefer subscriptions |

**Why Lifetime at $9.99?**
- ≈ 3.3 months of monthly subscription → users perceive it as a great deal
- One-time payment eliminates churn and refund requests
- Zero marginal cost per user → high profit margin at scale
- Matches user expectation: "I bring my own API, I pay once for the tool"

## Free Tier
- Create 1 learning path (full functionality)
- AI path generation (1 time)
- Daily task tracking
- Basic progress statistics
- Today's tasks widget
- System notification reminders
- Use your own API key (OpenAI, DeepSeek, Ollama, etc.)

## Pro Features (Unlocked with purchase)
- Unlimited learning paths
- AI path adjustment (unlimited)
- Detailed learning statistics (charts + trends)
- Export learning reports (PDF)
- Custom widget styles
- Saved AI configuration profiles (unlimited)
- Priority AI generation speed

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial on Yearly subscription only
- **Default selection**: Lifetime (recommended)
- Trial users get full Pro access during trial period

## Paywall UI Strategy

```
┌──────────────────────────────────────────────┐
│          Unlock PathForge Pro                 │
│                                               │
│  ⭐ LIFETIME (Recommended)                    │
│  $9.99 one-time                               │
│  ✓ All Pro features forever                   │
│  ✓ No subscriptions, no renewals              │
│  [ Get Lifetime Access ]  ← Default selected  │
│                                               │
│  ──────────────────────────────────────       │
│                                               │
│  📅 MONTHLY                                   │
│  $2.99/month                                  │
│  [ Subscribe Monthly ]                        │
│                                               │
│  📅 YEARLY (Save 50%)                         │
│  $14.99/year · 7-day free trial               │
│  [ Start Free Trial ]                         │
│                                               │
│  ──────────────────────────────────────       │
│  Restore Purchases                            │
│  Terms of Use · Privacy Policy                │
└──────────────────────────────────────────────
```

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist

### Lifetime Purchase (Non-Consumable)
- [ ] Product created in App Store Connect as Non-Consumable
- [ ] Screenshot and description submitted for review
- [ ] Restore purchases button implemented

### Subscription (Auto-Renewable)
- [ ] Subscription group created in App Store Connect
- [ ] Auto-renewal terms included in Terms of Use
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated on paywall
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented
- [ ] Subscription management link in Settings

## Technical Implementation Notes

### SubscriptionManager Updates Needed
1. Add `isLifetimeUser` property (checks Non-Consumable IAP)
2. `isProUser` = `isLifetimeUser || isSubscriptionActive`
3. Paywall shows 3 options with Lifetime as default
4. Purchase flow handles both Non-Consumable and Auto-Renewable types

### UserDefaults Keys
- `has_lifetime_purchase` (Bool) - set when Non-Consumable IAP completes
- `subscription_expiry_date` (Date) - for subscription users
- Existing `free_paths_created` remains for free tier tracking
