# Smart QR-Based Attendance Management Mobile Application

A production-ready Flutter mobile application for corporate attendance tracking with dynamic QR code generation, real-time expiry countdown, camera barcode scanning, GPS geolocation capture, and offline-first local SQLite persistence.

Built following a clean **BLoC / Cubit** architecture (no `Provider`, `GetX`, `Riverpod`, or `setState`), featuring role-based dashboards for **Admin** and **Employee**.

---

## 🌟 Key Features

### 1. 🔐 Role-Based Authentication
- **Secure Session Persistence**: Powered by `SharedPreferences`.
- **Role Redirection**: Automatic routing to **Admin Dashboard** (`/admin-dashboard`) or **Employee Dashboard** (`/home`).
- **Protected Routes**: Non-admin users cannot access administrative screens.
- **Preconfigured Demo Credentials**:
  - **Admin**:
    - **ID / Email**: `ADM001` or `admin@test.com`
    - **Password**: `admin123`
    - **Role**: `admin`
  - **Employee**:
    - **ID / Email**: `EMP001` or `john@test.com`
    - **Password**: `employee123`
    - **Role**: `employee`

### 2. 👨‍💼 Employee Dashboard (`/home`)
- Displays employee avatar, name, ID, role, and current date.
- Real-time today's attendance status badge:
  - 🟢 **Checked In**
  - 🔵 **Checked Out**
  - ⚪ **Not Checked In**
- Formatted Check-in and Check-out timestamps.
- One-tap navigation to **Scan QR Code** and **Attendance History**.
- Safe session logout with confirmation modal.

### 3. 🛡️ Admin Dashboard & QR Generator (`/admin-dashboard`, `/qr-generator`)
- **Executive Metric Cards**:
  - Total Staff Count
  - Present Employees (`checked_in`)
  - Checked Out Staff (`checked_out`)
  - Not Checked In (`absent`)
- **Dynamic Attendance QR Generation**:
  - Generates a unique UUID-based `sessionId`.
  - Encodes payload: `{"sessionId": "...", "generatedAt": "...", "expiresAt": "..."}`.
  - Strict **2-minute expiration limit**.
  - **Live Countdown Timer & Visual Progress Bar** driven purely by `QrGeneratorCubit` (no `setState`).
  - Automatically transitions to an **Expired** state after 120 seconds.
  - One-tap generation of fresh QR sessions.
- **Real-Time Staff Audit**:
  - Live feed of all employee records for the day.
  - Master historical audit log of all attendances (`/employee-attendance`).

### 4. 📷 QR Scanner & Smart Attendance Logic (`/qr-scanner`)
- Real-time device camera scanning powered by `mobile_scanner`.
- **Automatic Attendance Flow**:
  - **First Scan of the Day**: Marks **Check-In** with timestamp and GPS coordinates.
  - **Second Scan of the Day**: Marks **Check-Out** with timestamp and GPS coordinates.
- **Strict Validation Rules**:
  - Rejects expired QR codes (> 2 minutes).
  - Rejects tampered / invalid QR codes.
  - **Duplicate Prevention**: Rejects duplicate check-ins when already checked in.
  - **Duplicate Prevention**: Rejects further scans when already checked out for the day.
  - Enforces mandatory GPS location capture before committing records.
  - Debounced scanning preventing repeated camera trigger storms.
  - Manual QR input modal fallback (for Android Emulators / desktop environments without physical cameras).

### 5. 📍 GPS Geolocation Capture
- Integrates `geolocator` to capture high-precision `latitude` and `longitude` at the exact moment of check-in and check-out.
- Robust handling of:
  - Disabled GPS location services (prompts user to enable).
  - Location permission denied.
  - Location permission permanently denied (directs to App Settings).

### 6. 🗄️ Offline SQLite Storage
- Stored locally using `sqflite` inside `attendance.db`.
- Database Table Schema:
  ```sql
  CREATE TABLE attendance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employeeId TEXT NOT NULL,
    employeeName TEXT NOT NULL,
    date TEXT NOT NULL,
    checkInTime TEXT,
    checkOutTime TEXT,
    checkInLatitude REAL,
    checkInLongitude REAL,
    checkOutLatitude REAL,
    checkOutLongitude REAL,
    status TEXT NOT NULL DEFAULT 'not_checked_in',
    UNIQUE(employeeId, date)
  );
  ```
- Guaranteed single daily attendance per employee via composite `UNIQUE(employeeId, date)` constraint.

### 7. 🌐 Dio REST API Service
- Reusable `ApiService` with standard timeouts and headers.
- Integrated repository endpoints for authentication and attendance records with graceful local fallback.

---

## 🏗️ Architecture & Project Structure

The codebase strictly follows a clean **feature-based folder structure** using **BLoC / Cubit** for 100% of state management and UI interactions.

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Palette: primary, status badges, surfaces
│   │   └── app_constants.dart       # Keys, DB config, credentials
│   ├── routes/
│   │   └── app_routes.dart          # Named routes map
│   ├── services/
│   │   ├── api_service.dart         # Reusable Dio client
│   │   ├── database_service.dart    # SQLite singleton & table creation
│   │   └── location_service.dart    # Geolocator permissions & coordinates
│   ├── theme/
│   │   └── app_theme.dart           # Material 3 light theme definition
│   ├── utils/
│   │   └── app_helpers.dart         # Date, time, and coordinates formatters
│   └── widgets/
│       ├── app_error_widget.dart    # Standardized error component
│       ├── loading_widget.dart      # Standardized loading indicator
│       └── status_badge.dart        # Dynamic attendance status badge
├── data/
│   ├── models/
│   │   ├── attendance_model.dart    # SQLite entity with toMap/fromMap/copyWith
│   │   ├── employee_model.dart      # Employee user model & role helpers
│   │   └── qr_session_model.dart    # QR payload with JSON & expiry logic
│   └── repositories/
│       ├── attendance_repository.dart# SQLite CRUD & check-in/out logic
│       ├── auth_repository.dart     # Authentication & SharedPreferences session
│       └── qr_repository.dart       # Session generation & expiry validation
├── features/
│   ├── admin/
│   │   ├── cubit/
│   │   │   ├── admin_cubit.dart     # Dashboard counters & audit loader
│   │   │   └── admin_state.dart
│   │   └── views/
│   │       ├── admin_dashboard_view.dart    # Admin metrics & quick actions
│   │       └── employee_attendance_view.dart# Master attendance audit list
│   ├── attendance/
│   │   ├── cubit/
│   │   │   ├── attendance_cubit.dart # History & details loader
│   │   │   └── attendance_state.dart
│   │   └── views/
│   │       ├── attendance_details_view.dart # Full record with GPS & working hours
│   │       └── attendance_history_view.dart # Employee personal log
│   ├── auth/
│   │   ├── cubit/
│   │   │   ├── auth_cubit.dart      # Login, logout, session check, toggle visibility
│   │   │   └── auth_state.dart
│   │   └── views/
│   │       └── login_view.dart      # Material 3 sign-in with demo shortcuts
│   ├── home/
│   │   ├── cubit/
│   │   │   ├── home_cubit.dart      # Loads employee dashboard state
│   │   │   └── home_state.dart
│   │   └── views/
│   │       └── home_view.dart       # Employee dashboard UI
│   ├── qr_generator/
│   │   ├── cubit/
│   │   │   ├── qr_generator_cubit.dart # 2-minute timer & expiration
│   │   │   └── qr_generator_state.dart
│   │   └── views/
│   │       └── qr_generator_view.dart  # QR visualizer & countdown bar
│   └── qr_scanner/
│       ├── cubit/
│       │   ├── qr_scanner_cubit.dart   # Validation, GPS capture & mark attendance
│       │   └── qr_scanner_state.dart
│       └── views/
│           └── qr_scanner_view.dart    # Camera scanner & result views
└── main.dart                        # App entry point & initial route resolver
```

---

## 🔄 Attendance Flow Walkthrough

```
[Admin Generates QR]
       │
       ▼
1. Admin opens QR Generator (/qr-generator).
2. QrGeneratorCubit creates unique sessionId with a 2-minute expiration timestamp.
3. Live countdown bar ticks down every second.
       │
[Employee Scans QR]
       │
       ▼
4. Employee logs in and opens Scanner (/qr-scanner).
5. Camera captures and decodes QR JSON payload.
6. QrScannerCubit validates:
   ├─ Is QR expired? ──► YES: Displays error "QR code has expired".
   ├─ Is format valid? ─► NO: Displays error "Invalid QR format".
   └─ Valid? ──────────► Checks Employee login session.
7. LocationService captures current GPS Coordinates (Latitude, Longitude).
8. AttendanceRepository queries SQLite:
   ├─ No record for today ──────► Inserts new record -> "Check-in successful!".
   ├─ Status is "checked_in" ────► Updates record with checkOutTime & GPS -> "Check-out successful!".
   └─ Status is "checked_out" ───► Rejects -> "Already completed attendance today".
9. Employee Dashboard updates instantly via HomeCubit.
```

---

## 🚀 Setup & Running Instructions

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.0.0`)
- Android Studio / VS Code with Flutter extension
- Android Device or Emulator with GPS enabled

### Step 1: Clone or Navigate to the Project
```bash
cd emp-management
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run Static Code Analysis
Verify that the project has 0 errors:
```bash
flutter analyze
```

### Step 4: Run Unit and Widget Tests
```bash
flutter test
```

### Step 5: Launch the Application
- **On Android Physical Device or Emulator**:
  ```bash
  flutter run
  ```
- **On Chrome (Web Preview)**:
  ```bash
  flutter run -d chrome
  ```
- **On Windows Desktop**:
  ```bash
  flutter run -d windows
  ```

---

## 📱 Permissions Configured

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🧪 Testing Verification Summary
All unit tests and widget tests pass successfully:
- `test/models_test.dart`: Serialization, copyWith, role checks.
- `test/qr_test.dart`: JSON payload validation, dynamic expiry checks.
- `test/widget_test.dart`: Smoke test initializing root application on Login view.
