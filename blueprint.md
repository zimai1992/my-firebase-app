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

## 4. Technical Details
- **State Management**: `provider` package.
- **Backend**: Firebase (Auth, Firestore).
- **AI**: Google Generative AI (Gemini 1.5 Flash).
- **Charts**: `fl_chart`.
- **PDF**: `pdf` and `printing` packages.
- **Storage**: `shared_preferences` and Firestore.

## 5. Design & Theme (Material 3)
- **Primary Color**: Deep Medical Teal (`0xFF009688`).
- **Typography**: Poppins (with system sans-serif fallback for offline/restricted environments).
- **Visual Effects**: Custom cards with soft shadows and textured backgrounds.

## 6. Troubleshooting & Environment Notes (IDX/Emulator)
- **Firebase Auth/Firestore (Android)**: If you see `DEVELOPER_ERROR` or `PERMISSION_DENIED` in the Android emulator:
    1. Ensure the SHA-1 fingerprint of your debug keystore is added to the Firebase Console.
    2. To get the SHA-1, run `./gradlew signingReport` in the `android` folder.
    3. Firestore rules have been optimized for `collectionGroup` queries and caregiver access.
- **Font Loading**: `google_fonts` may fail in restricted networks (like the IDX emulator). The app handles this gracefully by falling back to system fonts.
- **Web Preview**: For the most stable development experience in IDX, use the **Web Preview**, which bypasses Android-specific certificate requirements.

## 7. Future Roadmap
- Integration with smart pillboxes via Bluetooth.
- Direct pharmacy refill requests.
- Multi-user profiles for families.
