# Project Blueprint: Medicine Reminder App

## 1. Overview

This document outlines the architecture, features, and design of the Medicine Reminder application. The app is a comprehensive mobile solution designed to help users manage their medications effectively. It provides features for tracking medicines, receiving timely reminders, managing stock, and offers premium features for advanced users. The application is built with a focus on user experience, clarity, and accessibility.

## 2. Project Structure & Architecture

The project follows a feature-driven, layered architecture to ensure a clean separation of concerns and maintainability.

- **`lib/`**: Main source code directory.
  - **`models/`**: Data models (e.g., `Medicine`, `User`).
  - **`providers/`**: State management (e.g., `MedicineProvider`, `LocaleProvider`).
  - **`screens/`**: UI for each screen of the application.
  - **`services/`**: Business logic and external services (e.g., `GeminiService`, `NotificationService`).
  - **`theme/`**: Theming and styling.
  - **`widgets/`**: Reusable UI components.
  - **`l10n/`**: Localization files.
  - **`main.dart`**: Application entry point.

## 3. Core Features

The application includes the following features:

- **Onboarding (Feature Tour)**: A multi-page tour (`FeatureTourScreen`) introduces new users to the app's key features, with a smooth page indicator for better UX.
- **User Authentication**: A simple login screen (`LoginScreen`) captures the user's name, which is stored in `SharedPreferences` for a personalized experience.
- **Medication Management**: Users can add, view, and delete medications. The `HomeScreen` displays a list of medicines, and the `AddMedicineScreen` provides a form for adding new ones.
- **Prescription Scanning with AI**: The app uses the device camera and AI to scan prescriptions, automatically extracting medication details to simplify adding new medicines.
- **Stock Management**: The app tracks the number of pills for each medicine, displays a "pills left" count, and shows a "Refill" button when stock is low.
- **Personalized Experience**: The `HomeScreen` greets the user by name and and displays a summary of their daily medication schedule.
- **Localization & Internationalization**: The app supports multiple languages (English, Malay, Chinese) using the `intl` package and `.arb` files.
- **Accessibility**: The app is designed with accessibility in mind, including semantic labels for UI elements.
- **Premium Features (Paywall)**: A paywall screen (`PaywallScreen`) offers premium features through a subscription model, managed via RevenueCat.

## 4. Caregiver Monitoring

This feature allows users to share their medication data with caregivers for monitoring and support.

- **Database Structure**:
    - A `users` collection in Firestore will store user data.
    - Each user document will have a `caregivers` subcollection.
- **UI Updates**:
    - **Settings Screen**: A "Share My Data" button will generate and display a unique 6-digit code. An "Add Caregiver" button allows the user to add a caregiver by entering their email.
- **Dashboard**:
    - A `CaregiverDashboard` will display the medicine logs of the users being monitored.

## 5. Technical Details

- **State Management**: `provider` for dependency injection and state management.
- **Routing**: `MaterialPageRoute` for basic navigation.
- **HTTP Client**: `http` for making API calls.
- **Local Storage**: `shared_preferences` for storing simple key-value data.
- **Internationalization**: `flutter_localizations` and `intl`.
- **Firebase**:
    - `firebase_core`: For initializing Firebase.
    - `cloud_firestore`: For database operations.
    - `firebase_auth`: For user authentication.
- **AI & ML**:
    - `google_generative_ai`: For interacting with the Gemini API.
- **Notifications**:
    - `flutter_local_notifications`: For scheduling and displaying local notifications.

## 6. Design & Theme

The app uses a modern, clean design based on Material Design 3.

- **Colors**: A color scheme generated from a seed color (`Colors.deepPurple`).
- **Typography**: Custom fonts from the `google_fonts` package (`Oswald`, `Roboto`, `Open Sans`).
- **Theming**: Centralized `ThemeData` for both light and dark modes.
- **Layout**: Responsive layouts that adapt to different screen sizes.

## 7. Testing

- **Unit and Widget Testing**: The project includes a suite of unit and widget tests to ensure the correctness of individual components and features.
- **Mocking**: The `mockito` package is used to create mock objects for dependencies in tests.
- **Continuous Integration**: Tests are run automatically after every major change to ensure that new features do not break existing functionality.
