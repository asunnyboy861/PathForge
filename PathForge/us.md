# PathForge - iOS Development Guide

## Executive Summary

PathForge is an AI-powered learning path generator that acts as a personal GPS for learning anything. Targeting lifelong learners in the US market, it solves the "I don't know where to start" problem by generating personalized, structured study plans using OpenAI's GPT-4o-mini. Unlike Coursera's fixed paths or ChatGPT's generic responses, PathForge creates dynamic, week-by-week learning roadmaps with milestones, tasks, and curated resources that adapt to user feedback.

**Key Differentiators**:
- AI-generated personalized learning paths (not fixed course tracks)
- Path adjustment based on real-time user feedback
- Native iOS experience with offline support, widgets, and iCloud sync
- Focused on lifelong learners (not just students or exam prep)
- 7-day free trial with freemium conversion strategy

**Target Audience**: Self-directed learners aged 18-45 who want to learn new skills (programming, photography, public speaking, etc.) but struggle with information overload and scattered study plans.

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **SkillAI** | AI learning path generation, progress tracking | Web-only, no iOS native app, limited free tier | iOS native + offline + widgets + iCloud sync |
| **CareerTrack AI** | AI career plans, role matching, skill roadmaps | Career-focused only, no general skill learning, no widgets | Broader skill coverage + widgets + path adjustment |
| **Mindgrasp AI** | Study materials from lectures/PDFs, flashcards | Passive content consumption, no structured path planning | Active path generation + milestone tracking + progress |
| **StudyMap.ai** | YouTube/article to course conversion, structured chapters | Web platform, no native iOS, no offline, no widgets | Native iOS + offline + widgets + path adjustment |
| **Coursera** | Vast course catalog, certificates, recognized brands | Fixed curriculum, no personalization, expensive | AI-personalized paths, affordable subscription |
| **Udemy** | Huge course selection, frequent sales | Quality varies, no structured path, no progress tracking | Curated resources + quality scoring + progress tracking |

## Apple Design Guidelines Compliance

- **Clarity**: Clean information hierarchy with clear task lists, progress indicators, and milestone markers
- **Deference**: Content-first design with minimal chrome, letting learning paths take center stage
- **Depth**: Navigation stack for path hierarchy, modal sheets for task details, smooth transitions
- **Consistency**: Native iOS components (List, NavigationStack, TabView), SF Symbols, system fonts
- **Liquid Glass**: Adopt modern iOS 26 glass materials for tab bars and navigation where appropriate
- **Accessibility**: Dynamic Type support, VoiceOver labels, high contrast colors, minimum touch target 44pt
- **Dark Mode**: Full support with semantic colors (Forge Blue adapts to light/dark)
- **iPad**: Adaptive layouts with max-width constraints, no restrictive sidebar styles

## Technical Architecture

- **Language**: Swift 5.9+ / Swift 6 concurrency
- **Framework**: SwiftUI (primary), SwiftData for persistence
- **AI**: OpenAI API (GPT-4o-mini) via MacPaw/OpenAI Swift package
- **Data**: SwiftData (local) + CloudKit (iCloud sync, optional)
- **Networking**: URLSession + async/await (native, no third-party)
- **Widgets**: WidgetKit for home screen progress + daily tasks
- **Notifications**: UserNotifications for study reminders
- **Charts**: Swift Charts for learning statistics
- **IAP**: StoreKit 2 for subscription management
- **Dependencies**: SPM with MacPaw/OpenAI only

## Module Structure

```
PathForge/
├── App/
│   └── PathForgeApp.swift
├── Models/
│   ├── StudyPath.swift
│   ├── Milestone.swift
│   ├── StudyTask.swift
│   └── LearningResource.swift
├── Services/
│   ├── OpenAIService.swift
│   ├── PathGenerationService.swift
│   ├── PromptBuilder.swift
│   ├── SubscriptionManager.swift
│   └── NotificationManager.swift
├── ViewModels/
│   ├── PathGenerationViewModel.swift
│   ├── HomeViewModel.swift
│   ├── PathDetailViewModel.swift
│   ├── StatsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── PathGeneration/
│   │   ├── PathGenerationView.swift
│   │   ├── GoalInputStep.swift
│   │   ├── LevelAssessmentStep.swift
│   │   ├── TimePreferencesStep.swift
│   │   └── PathPreviewStep.swift
│   ├── PathDetail/
│   │   └── PathDetailView.swift
│   ├── Stats/
│   │   └── StatsView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   ├── Paywall/
│   │   └── PaywallView.swift
│   └── Components/
│       ├── TaskRowView.swift
│       ├── MilestoneCardView.swift
│       ├── ProgressRingView.swift
│       └── PathCardView.swift
├── Widgets/
│   ├── TodayTasksWidget.swift
│   └── ProgressWidget.swift
└── Extensions/
    ├── Color+Theme.swift
    └── Date+Extensions.swift
```

## Implementation Flow

1. Set up SwiftData models (StudyPath, Milestone, StudyTask, LearningResource)
2. Implement OpenAI service with MacPaw/OpenAI package
3. Build PathGenerationService with prompt engineering
4. Create PathGenerationViewModel with step-by-step wizard
5. Build PathGenerationView (4-step wizard: Goal → Level → Time → Preview)
6. Implement HomeView with today's tasks and path cards
7. Build PathDetailView with milestone/task management
8. Create StatsView with Swift Charts
9. Implement SubscriptionManager with StoreKit 2
10. Build PaywallView with subscription options
11. Add SettingsView with API key config, notifications, iCloud toggle
12. Implement ContactSupportView
13. Add WidgetKit widgets (Today Tasks + Progress Ring)
14. Configure notification scheduling
15. Add CloudKit sync (optional toggle in Settings)
16. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: Forge Blue (#007AFF / system blue)
  - Success: Path Green (#34C759 / system green)
  - Warning: Alert Orange (#FF9500 / system orange)
  - Background Light: #FFFFFF, Dark: #000000
  - Card Light: #F2F2F7, Dark: #1C1C1E
  - Text Primary: label color, Secondary: secondaryLabel

- **Typography**: SF Pro system fonts
  - Large Title: 34pt Bold
  - Title: 28pt Bold
  - Headline: 17pt Semibold
  - Body: 17pt Regular
  - Caption: 13pt Regular

- **Layout**:
  - Standard margins: 16pt horizontal, 8pt vertical
  - Card corner radius: 12pt
  - Card padding: 16pt
  - Max content width on iPad: 720pt with .frame(maxWidth: .infinity)
  - Tab bar: 4 tabs (Home, Paths, Stats, Settings)

- **Animations**: 
  - Path generation: shimmer loading effect
  - Task completion: checkmark bounce
  - Progress: smooth ring fill animation
  - Navigation: standard iOS push/pop transitions

## Code Generation Rules

- Use @Observable macro (not ObservableObject) for ViewModels
- Use SwiftData @Model for all data models
- Use async/await for all network calls
- No force unwraps, no implicit optionals
- All SwiftData attributes must be optional or have defaults
- All relationships must have inverse relationships
- Use semantic color names (.blue, .green) not hex values in SwiftUI
- iPad: always add .frame(maxWidth: 720).frame(maxWidth: .infinity) for main ScrollView content
- Never use .tabViewStyle(.sidebarAdaptable)
- No comments in code unless asked

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.PathForge
2. Verify Deployment Target: iOS 17.0
3. Add MacPaw/OpenAI SPM dependency
4. Configure App Icon (1024x1024)
5. Enable Push Notifications capability
6. Enable iCloud + CloudKit capability
7. Configure StoreKit 2 subscription products
8. Create StoreKit Configuration file for testing
9. Build and test on iPhone XS Max simulator
10. Build and test on iPad Pro 13-inch (M4) simulator
11. Push to GitHub repository
12. Deploy policy pages to GitHub Pages
