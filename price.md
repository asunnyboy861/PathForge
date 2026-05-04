# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: PathForge Pro
- **Group ID**: Auto-generated in App Store Connect

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.PathForge.monthly`
- **Price**: $4.99 per month
- **Display Name**: PathForge Pro Monthly
- **Description**: Full access to all Pro features
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.PathForge.yearly`
- **Price**: $29.99 per year (50% savings vs monthly)
- **Display Name**: PathForge Pro Yearly
- **Description**: Best value - save 50% annually
- **Localization**: English (US)

## Free Tier
- Create 1 learning path (full functionality)
- AI path generation (1 time)
- Daily task tracking
- Basic progress statistics
- Today's tasks widget
- System notification reminders

## Pro Features (Locked behind subscription)
- Unlimited learning paths
- AI path adjustment (10x monthly / 20x yearly)
- Detailed learning statistics (charts + trends)
- Export learning reports (PDF)
- Custom widget styles
- Priority AI generation speed

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid)
- **Default selection**: Yearly plan (best value)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented
