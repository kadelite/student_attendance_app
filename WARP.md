# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Flutter Commands
```bash
# Get dependencies
flutter pub get

# Run the application
flutter run

# Build for release
flutter build apk --release
flutter build appbundle --release

# Run tests
flutter test

# Run code analysis/linting
flutter analyze

# Format code
dart format .

# Generate code (for Hive models)
dart run build_runner build
```

### Platform-specific Commands
```bash
# Run on specific device
flutter run -d windows
flutter run -d android
flutter run -d ios

# Build for specific platforms
flutter build windows --release
flutter build apk --target-platform android-arm64
flutter build ios --release
```

## Architecture Overview

This is a **Flutter-based Student Attendance Management System** with role-based authentication supporting three user types: Students, Teachers, and Admins.

### Key Architecture Components

**Authentication & User Management:**
- Firebase Authentication integration with fallback offline mode
- Role-based access control (Student/Teacher/Admin)
- Email validation for school domains (.edu domains)
- Local data persistence using SharedPreferences

**Data Layer:**
- **Models:** `UserModel`, `AttendanceModel` with serialization support
- **Services:** Singleton pattern services for authentication and attendance management
- **Storage:** Mixed approach using Firebase + local storage (Hive, SharedPreferences)

**Navigation & UI:**
- Role-based dashboard routing after authentication
- Material Design 3 theming with custom color scheme
- Splash screen with automatic role-based navigation

### Core Services

1. **AuthService** (`lib/services/auth_service.dart`)
   - Handles registration, login, logout, password reset
   - Validates school email domains
   - Manages user session persistence

2. **AttendanceService** (`lib/services/attendance_service.dart`)
   - Marks and retrieves attendance records
   - Manages teacher-student relationships
   - Provides attendance statistics and date filtering

### Directory Structure
```
lib/
├── main.dart                 # App entry point with theme and routing
├── models/                   # Data models
│   ├── user_model.dart       # User/authentication model
│   └── attendance_model.dart # Attendance record model
├── services/                 # Business logic layer
│   ├── auth_service.dart     # Authentication service
│   ├── attendance_service.dart # Attendance management
│   └── pdf_service.dart      # PDF generation for reports
└── screens/                  # UI screens by role
    ├── auth/                 # Login/registration screens
    ├── student/              # Student dashboard
    ├── teacher/              # Teacher dashboard
    └── admin/                # Admin dashboard
```

## Key Dependencies

**Core Framework:**
- Flutter SDK ^3.9.2
- Firebase (Core + Auth) for authentication
- Provider for state management

**Data & Storage:**
- `hive` + `hive_flutter` for local object storage
- `shared_preferences` for simple key-value storage
- `http` for API calls

**UI & Features:**
- `go_router` for advanced routing
- `qr_flutter` + `qr_code_scanner` for QR attendance
- `pdf` + `path_provider` for report generation
- `email_validator` for email validation

## Development Notes

### Firebase Setup
The app is configured for Firebase Authentication but requires setup:
1. See `FIREBASE_SETUP.md` for detailed instructions
2. Update `lib/firebase_options.dart` with your Firebase config
3. Update `web/firebase-config.js` with your Firebase config
4. App falls back to local storage when Firebase is not configured

### Authentication Flow
1. App starts with splash screen checking authentication state
2. Routes to login screen if not authenticated
3. After login, routes to role-specific dashboard (Student/Teacher/Admin)
4. Firebase auth with offline fallback using local storage

### Data Persistence Strategy
- User data: SharedPreferences (JSON serialized)
- Attendance records: SharedPreferences with JSON arrays
- Offline-first approach with optional Firebase sync

### QR Code Feature
The app includes QR code functionality for attendance tracking - teachers can generate QR codes and students can scan them to mark attendance.

### Testing
- Widget tests are located in `test/widget_test.dart`
- Run tests with `flutter test`

## Code Generation Requirements

When modifying Hive models or adding new ones:
1. Add `@HiveType()` and `@HiveField()` annotations
2. Run `dart run build_runner build` to generate adapters
3. Register adapters in `main.dart` during Hive initialization