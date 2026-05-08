# Pricing Configuration

## Monetization Model: Three-Tier Pricing

## Core Insight
PathForge uses user-provided API keys, meaning **zero API cost for the developer**.
The app is a pure local tool with SwiftData storage.
A **three-tier pricing model** gives users flexibility: try monthly, save with yearly, or commit with lifetime.

## Pricing Structure

| Tier | Price | Description | Target User |
|------|-------|-------------|-------------|
| **Monthly** | $2.99/month | Entry-level, flexible | Users who want to try before committing |
| **Yearly** | $14.99/year | Save 58% vs monthly | Users who see value after 1-2 months |
| **Lifetime** | $29.99 (one-time) | Best value, permanent | Power users who want to lock in forever |

### Pricing Logic
- **Monthly ($2.99)**: Low barrier to entry, serves as a paid trial
- **Yearly ($14.99)**: Cheaper than 5 months of monthly ($2.99 × 5 = $14.95), incentivizes annual commitment
- **Lifetime ($29.99)**: Cheaper than 2 years of yearly ($14.99 × 2 = $29.98), incentivizes long-term commitment

**Break-even analysis**:
- Monthly → Yearly: Breaks even at 5 months ($2.99 × 5 = $14.95 ≈ $14.99)
- Yearly → Lifetime: Breaks even at 2 years ($14.99 × 2 = $29.98 ≈ $29.99)
- Monthly → Lifetime: Breaks even at 10 months ($2.99 × 10 = $29.90 ≈ $29.99)

## Product Configuration

### PathForge Pro Monthly
- **Reference Name**: PathForge Pro Monthly
- **Product ID**: `com.zzoutuo.PathForge.pro.monthly`
- **Price**: $2.99/month
- **IAP Type**: Auto-Renewable Subscription

### PathForge Pro Yearly
- **Reference Name**: PathForge Pro Yearly
- **Product ID**: `com.zzoutuo.PathForge.pro.yearly`
- **Price**: $14.99/year
- **IAP Type**: Auto-Renewable Subscription

### PathForge Pro Lifetime
- **Reference Name**: PathForge Pro Lifetime
- **Product ID**: `com.zzoutuo.PathForge.pro.lifetime`
- **Price**: $29.99 (one-time)
- **IAP Type**: Non-Consumable

## Free Tier
- Create 1 learning path (full functionality)
- AI path generation (1 time)
- Daily task tracking
- Basic progress statistics
- Today's tasks widget
- System notification reminders
- Use your own API key (OpenAI, DeepSeek, Ollama, etc.)

**The free tier IS the trial.** No separate free trial is needed.

## Pro Features (Unlocked with any purchase)
- Unlimited learning paths
- AI path adjustment (unlimited)
- Detailed learning statistics (charts + trends)
- Export learning reports (PDF)
- Custom widget styles
- Saved AI configuration profiles (unlimited)

## Paywall UI Strategy

```
┌──────────────────────────────────────────────┐
│          Unlock PathForge Pro                 │
│                                               │
│           👑                                  │
│                                               │
│     Unlock Your Full Potential                │
│     You bring the API key. We provide         │
│     the tools.                                │
│                                               │
│  ✓ Unlimited Learning Paths                   │
│  ✓ AI Path Adjustment                         │
│  ✓ Detailed Statistics                        │
│  ✓ Export Reports (PDF)                       │
│  ✓ Custom Widgets                             │
│  ✓ Saved AI Profiles                          │
│                                               │
│  ┌────────────────────────────────────┐       │
│  │  ○ Monthly    $2.99/month          │       │
│  │  ○ Yearly     $14.99/year          │       │
│  │  ● Lifetime   $29.99 (Best Value)  │       │
│  └────────────────────────────────────┘       │
│                                               │
│        [ Get Lifetime Access ]                │
│                                               │
│  Restore Purchases                            │
│  Terms of Use · Privacy Policy                │
└──────────────────────────────────────────────┘
```

## Policy Pages Required
- Support Page: ✅
- Privacy Policy: ✅
- Terms of Use: ✅

## Apple IAP Compliance Checklist

### Lifetime Purchase (Non-Consumable)
- [ ] Product created in App Store Connect as Non-Consumable
- [ ] Screenshot and description submitted for review
- [ ] Restore purchases button implemented
- [ ] Price displayed clearly on paywall

### Subscription Plans (Auto-Renewable)
- [ ] Monthly and Yearly products created in App Store Connect
- [ ] Subscription group configured
- [ ] Free trial (optional) configured for yearly
- [ ] Restore purchases button implemented

## Technical Implementation Notes

### SubscriptionManager
1. Load all three products: monthly, yearly, lifetime
2. `isProUser` = purchased Lifetime OR active subscription
3. `isLifetimeUser` = purchased Non-Consumable IAP
4. Track subscription expiration for yearly/monthly

### UserDefaults Keys
- `has_lifetime_purchase` (Bool) - set when Non-Consumable IAP completes
- `saved_ai_profiles` - for saved AI configurations
- `free_paths_created` - for free tier tracking
