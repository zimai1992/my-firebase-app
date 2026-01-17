# Project Blueprint: Medicine Reminder App

## 1. Overview
This document outlines the architecture, features, and design of the Medicine Reminder application. The app is a comprehensive mobile solution designed to help users manage their medications effectively. It provides features for tracking medicines, receiving timely reminders, managing stock, and offers premium features for advanced users. The application is built with a focus on user experience, clarity, and accessibility, particularly for elderly users or those with chronic conditions.

## 2. Project Structure & Architecture
The project follows a feature-driven, layered architecture to ensure a clean separation of concerns and maintainability.

- **`lib/`**: Main source code directory.
  - **`models/`**: Data models (e.g., `Medicine`, `User`, `MedicineLog`, `Invitation`).
  - **`providers/`**: State management (e.g., `MedicineProvider`, `LocaleProvider`, `ThemeProvider`).
  - **`screens/`**: UI for each screen, organized by feature.
  - **`services/`**: Business logic and external services (e.g., `GeminiService`, `NotificationService`).
  - **`theme/`**: Centralized theming and styling logic with resilient font loading.
  - **`widgets/`**: Reusable UI components.
  - **`l10n/`**: Localization files (arb).
  - **`main.dart`**: Application entry point with robust initialization.

## 3. Core Features (Completed)
- **AI Prescription Scanning**: Uses Gemini Vision to extract medication details from photos.
- **AI Safety Check**: Uses Gemini to analyze drug-drug interactions between all active medications.
- **Inventory Management**: Tracks pill counts, logs doses, and alerts when stock is low.
- **Adherence Tracking**: Visualizes 7-day adherence trends using interactive charts (`fl_chart`).
- **Caregiver Hub**: Allows family members to monitor patient compliance and log physical visits.
- **Visit Mode**: A structured checklist for caregivers to use during physical check-ins.
- **Professional Reports**: Generates detailed PDF health reports for doctors.
- **Localization**: Supports English, Malay, and Chinese.
- **Emergency SOS**: Real-time Firestore alerts with haptic feedback for patient safety.
- **Voice Commands**: Voice-enabled logging and adherence checks ("Did I take my medicine?").
- **Gamification**: Adherence streaks and milestone badges (On Fire, Weekly Warrior, Monthly Master).
- **One-Tap Refill**: Google Maps integration for finding nearby pharmacies and refill planning.
- **Offline Persistence**: Full SQLite local database (Sqflite) for offline reliability.
- **Smart Watch Support**: Actionable notifications (Mark as Taken, Snooze) for Wear OS and watchOS.

## 4. Technical Details
- **State Management**: `provider` package.
- **Backend**: Firebase (Auth, Firestore).
- **Local Storage**: `sqflite` (Primary), `shared_preferences` (Settings).
- **AI**: Google Generative AI (Gemini 1.5 Flash).
- **Notifications**: `flutter_local_notifications` with custom actions.
- **Speech**: `speech_to_text` for elderly-friendly interaction.
- **Haptics**: `vibration` package for tactile confirmation.

## 5. Design & Theme (Material 3)
- **Dynamic Theming**: Gradients that change based on the time of day (Morning/Afternoon/Evening).
- **Pill Customization**: Customizable shapes (Round, Capsule, Liquid, Square) and colors.
- **Focus UI**: Large, prominent "Next Dose" cards on the home screen.
- **Skeleton Loading**: Shimmer effects for a premium loading experience.
- **Interactive Onboarding**: Fluid welcome flow with `smooth_page_indicator`.

## 6. Future Roadmap
- Integration with smart pillboxes via Bluetooth.
- Direct pharmacy API integration for automatic refill orders.
- Multi-user family profiles.
