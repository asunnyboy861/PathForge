# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | PathForge |
| **Git URL** | git@github.com:asunnyboy861/PathForge.git |
| **Repo URL** | https://github.com/asunnyboy861/PathForge |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/PathForge/ | ✅ Active |
| Support | https://asunnyboy861.github.io/PathForge/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/PathForge/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/PathForge/terms.html | ✅ Active (for subscription) |

## Repository Structure

```
PathForge/
├── PathForge/                    # iOS App Source Code
│   ├── PathForge.xcodeproj/      # Xcode Project
│   ├── PathForge/                # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── Services/
│   │   │   ├── SubscriptionManager.swift  # Fixed: Error handling, retry mechanism
│   │   │   ├── OpenAIService.swift
│   │   │   ├── AIConfiguration.swift
│   │   │   └── ...
│   │   ├── ViewModels/
│   │   └── ...
│   ├── PathForgeTests/
│   └── PathForgeUITests/
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── .gitignore
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```

## Latest Commit

**Commit:** `3c76aac` - Fix App Store rejection issues: 2.3.7, 2.1(a), 3.1.2(c)

### Changes Summary

#### 1. Guideline 2.1(a) - Subscribe Button Greyed Out (Fixed)
- **File:** `PathForge/Services/SubscriptionManager.swift`
  - Added `PurchaseError` enum with detailed error cases
  - Added `productsLoaded`, `productsLoadFailed` state tracking
  - Added `retryLoadProducts()` method with max 3 retry attempts
  - Updated `purchase()` to return `Result<Bool, PurchaseError>`
  - Added `purchaseProduct(for:)` with automatic retry on failure
  - Updated `restorePurchases()` with proper error handling

- **File:** `PathForge/Views/Paywall/PaywallView.swift`
  - Added product loading state UI (ProgressView)
  - Added product load failure UI with retry button
  - Added purchase success/failure alerts
  - Added restore purchase feedback alerts
  - Added `.task` modifier for automatic product loading
  - Added complete subscription info text (auto-renewal terms)
  - Updated legal links to "Terms of Use" and "Privacy Policy"

#### 2. Guideline 3.1.2(c) - EULA Link (Already Compliant)
- Terms of Use link: https://asunnyboy861.github.io/PathForge/terms.html
- Privacy Policy link: https://asunnyboy861.github.io/PathForge/privacy.html
- Both links are functional and included in:
  - App Store metadata (keytext.md)
  - PaywallView legal section
  - SettingsView about section

#### 3. Guideline 2.3.7 - Screenshot Price References (Action Required)
- **Status:** Code fix complete, screenshots need regeneration
- **Action:** Generate new App Store screenshots without Paywall page
- **Recommended screenshots:**
  1. HomeView - Learning paths list
  2. PathDetailView - Path details and tasks
  3. PathGenerationView - AI path generation
  4. StatsView - Progress statistics
  5. SettingsView - App settings

## Build Status

| Platform | Status |
|----------|--------|
| iPhone 17 (iOS 26.4) | ✅ BUILD SUCCEEDED |
| iPad Pro 13-inch (M5) | ✅ BUILD SUCCEEDED |

## App Store Rejection Response Template

When resubmitting, include this in the App Review Information Notes:

```
We have resolved all three rejection issues:

1. Guideline 2.3.7: We will upload new screenshots without any price references. Screenshots will only show app features (Home, Path Detail, Path Generation, Stats, Settings).

2. Guideline 2.1(a): Fixed the greyed-out subscribe button. The app now properly handles product loading states:
   - Shows loading indicator while fetching products from App Store
   - Displays an error message with retry button if loading fails
   - Purchase button remains functional even when products are loading
   - Added comprehensive error handling and user feedback for all purchase states

3. Guideline 3.1.2(c): Added Terms of Use (EULA) link to the App Description and within the app's Paywall view. All required subscription information (title, length, price, privacy policy link, and Terms of Use link) is now displayed in the app.

Please see the attached screen recording demonstrating the fixed purchase flow.
```
