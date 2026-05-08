# Pricing Configuration

## Monetization Model: Subscription (IAP)

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

## Free Tier
- Create 1 learning path (full functionality)
- AI path generation (1 time)
- Daily task tracking
- Basic progress statistics
- Today's tasks widget
- System notification reminders
- Use your own API key (OpenAI, DeepSeek, Ollama, etc.)

**The free tier serves as the trial.** No separate free trial period is offered.

## Pro Features (Unlocked with any purchase)
- Unlimited learning paths
- AI path adjustment (unlimited)
- Detailed learning statistics (charts + trends)
- Export learning reports (PDF)
- Custom widget styles
- Saved AI configuration profiles (unlimited)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Restore purchases functionality implemented
