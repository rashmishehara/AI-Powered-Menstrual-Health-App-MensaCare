# MensaCare - System Architecture Diagram

## High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            MENSACARE APPLICATION                             │
│                          (Flutter Mobile App)                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
        ┌───────────▼──────────┐  ┌──▼─────────────┐  ┌▼──────────────────┐
        │  PRESENTATION LAYER  │  │  SERVICES      │  │  DATA LAYER       │
        │  (UI/Features)       │  │  (Business     │  │  (Persistence)    │
        │                      │  │   Logic)       │  │                    │
        └──────────────────────┘  └────────────────┘  └────────────────────┘
```

---

## Detailed Architecture Layers

### 1. **PRESENTATION LAYER** (Features)
Handles all UI and user interactions organized by feature.

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (lib/features)                 │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │  auth/         │  │  home/           │  │  navigation/     │    │
│  │  ├─ login      │  │  ├─ home_screen  │  │  ├─ root_nav    │    │
│  │  ├─ register   │  │  └─ (Dashboard)  │  │  └─ (Routing)   │    │
│  │  └─ (Auth)     │  └──────────────────┘  └──────────────────┘    │
│  └────────────────┘                                                  │
│                                                                       │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │  calendar/     │  │  symptoms/       │  │  predictions/    │    │
│  │  ├─ calendar   │  │  ├─ add_symptoms │  │  ├─ predictions  │    │
│  │  └─ (Period    │  │  ├─ history      │  │  └─ (ML Results) │    │
│  │    Tracking)   │  │  └─ (Symptoms)   │  └──────────────────┘    │
│  └────────────────┘  └──────────────────┘                            │
│                                                                       │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │  analysis/     │  │  abnormalities/  │  │  education/      │    │
│  │  ├─ analysis   │  │  ├─ abnormalities│  │  ├─ cycle_info   │    │
│  │  └─ (Reports)  │  │  └─ (Alerts)     │  │  ├─ tips         │    │
│  └────────────────┘  └──────────────────┘  │  └─ (Info)       │    │
│                                             └──────────────────┘    │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              settings/                                        │ │
│  │              ├─ settings_screen                              │ │
│  │              └─ (User Profile & Settings)                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

### 2. **SERVICES LAYER** (Business Logic & AI)
Core services handling data processing and ML inference.

```
┌──────────────────────────────────────────────────────────────────────┐
│                     SERVICES LAYER (lib/services)                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  database_service.dart                                          │ │
│  │  ├─ User Management (CRUD)                                      │ │
│  │  ├─ Period Data Storage                                         │ │
│  │  ├─ Symptom Records                                             │ │
│  │  ├─ Health Metrics Storage                                      │ │
│  │  └─ Data Queries & Retrieval                                    │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  preprocessing.dart                                             │ │
│  │  ├─ Data Normalization                                          │ │
│  │  ├─ Feature Extraction                                          │ │
│  │  ├─ Data Validation                                             │ │
│  │  ├─ Input Preparation for ML Model                              │ │
│  │  └─ Data Cleaning                                               │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  inference_service.dart                                         │ │
│  │  ├─ TFLite Model Loading                                        │ │
│  │  │  (mensus_multilabel_weighted.tflite)                         │ │
│  │  ├─ Input Tensor Preparation                                    │ │
│  │  ├─ Run Inference (Predictions)                                 │ │
│  │  ├─ Output Parsing                                              │ │
│  │  └─ Abnormality Detection                                       │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

### 3. **DATA LAYER** (Persistence)
Local database storage and asset management.

```
┌──────────────────────────────────────────────────────────────────────┐
│                      DATA LAYER (Storage)                            │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────┐  ┌──────────────────────────┐   │
│  │  SQLite Database               │  │  Asset Resources         │   │
│  │  (via sqflite)                 │  │  (in assets/)            │   │
│  │  ├─ users table                │  │  ├─ images/             │   │
│  │  ├─ periods table              │  │  │  ├─ egg.png          │   │
│  │  ├─ symptoms table             │  │  │  ├─ 3d-report.png    │   │
│  │  ├─ health_metrics table       │  │  │  ├─ diet.png         │   │
│  │  ├─ notes table                │  │  │  └─ ...              │   │
│  │  ├─ abnormalities table        │  │  ├─ models/             │   │
│  │  └─ user_sessions table        │  │  │  └─ mensus_multilab  │   │
│  │                                │  │     el_weighted.tflite  │   │
│  │  Location: Device Storage      │  │                          │   │
│  │  (path_provider)               │  └──────────────────────────┘   │
│  └────────────────────────────────┘                                  │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTIONS                            │
│  (Login → Dashboard → Track Symptoms → Get Predictions)            │
└──────────────────────┬──────────────────────────────────────────────┘
                       │
                ┌──────▼───────┐
                │ PRESENTATION │
                │  (UI Layer)  │
                └──────┬───────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐    ┌────▼────┐   ┌────▼────┐
   │  Auth   │    │  Home   │   │ Calendar│
   │ Module  │    │ Module  │   │ Module  │
   └────┬────┘    └────┬────┘   └────┬────┘
        │              │              │
        │    ┌─────────┴──────────────┤
        │    │                        │
   ┌────▼────▼────┐           ┌──────▼───────┐
   │ Symptoms     │           │ Predictions  │
   │ Module       │           │ Module       │
   └────┬─────────┘           └──────┬───────┘
        │                            │
        │         ┌──────────────────┤
        │         │                  │
        └────┬────▼──────────────┬───▼──┐
             │   SERVICES LAYER  │      │
             ├───────────────────┤      │
             │                   │      │
        ┌────▼─────────┐    ┌────▼──────▼────┐
        │  Database    │    │ Preprocessing  │
        │  Service     │    │ + Inference    │
        └────┬─────────┘    │ Service        │
             │              └────┬───────────┘
             │                   │
        ┌────▼────────────┬──────▼────────────┐
        │                 │                   │
        │    ┌────────────▼──────┐    ┌───────▼──────┐
        │    │  SQLite Database  │    │ ML Model     │
        │    │ (User Data,       │    │ (TFLite)     │
        │    │  Symptoms,        │    │              │
        │    │  History)         │    │ Predictions: │
        │    │                   │    │ ├─ Normal    │
        │    │ Tables:           │    │ ├─ Abnormal  │
        │    │ ├─ users          │    │ └─ Alerts    │
        │    │ ├─ periods        │    └──────────────┘
        │    │ ├─ symptoms       │
        │    │ ├─ metrics        │
        │    │ └─ abnormalities  │
        │    └───────────────────┘
        │
        └─────────────────────────────────────────▶ Display Results to User
```

---

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         COMPONENT INTERACTIONS                          │
└─────────────────────────────────────────────────────────────────────────┘

LOGIN FLOW:
  LoginScreen ──(user credentials)──▶ DatabaseService ──(validate)──▶ SQLite
                                            ▲
                                            │
                                     ┌──────┴──────┐
                                     │ Return User │
                                     └──────┬──────┘
                                            ▼
                              Navigate to HomeScreen

SYMPTOM TRACKING FLOW:
  AddSymptomsScreen ──(symptom data)──▶ PreprocessingService ──▶ DatabaseService
                                          (normalize data)              ▼
                                                                    SQLite
                                                                    (store)
                                                                        │
                                                                        ▼
                                          InferenceService ◀────┐ Data Retrieved
                                          (prepare input for ML)│
                                                                 │
                                                    ┌────────────┘
                                                    │
                                        ┌───────────▼───────────┐
                                        │  TFLite Model         │
                                        │  (mensus_multilabel   │
                                        │   _weighted)          │
                                        └───────────┬───────────┘
                                                    │
                                                    ▼
                                        PredictionsScreen
                                        (display results)
                                        ├─ Cycle Phase
                                        ├─ Symptom Analysis
                                        └─ Abnormality Alerts

REPORT GENERATION FLOW:
  AnalysisScreen ──(request)──▶ DatabaseService ──(fetch history)──▶ SQLite
                                    │
                                    ▼
                            InferenceService
                            (run batch analysis)
                                    │
                                    ▼
                        Generate PDF Report
                        (using pdf package)
                                    │
                                    ▼
                        Share Report (share_plus)
```

---

## Key Features by Module

| Module | Features | Key Files |
|--------|----------|-----------|
| **Authentication** | User registration, login, password recovery | `auth/login_screen.dart`, `auth/register_screen.dart` |
| **Dashboard** | Welcome screen, quick actions | `home/home_screen.dart` |
| **Period Tracking** | Log period start date, track cycle | `calendar/calendar_screen.dart` |
| **Symptom Tracking** | Log daily symptoms, physical/mental/lifestyle | `symptoms/add_symptoms_screen.dart`, `symptoms/symptoms_history_screen.dart` |
| **ML Predictions** | Abnormality detection, cycle analysis | `predictions/predictions_screen.dart` |
| **Analysis & Reports** | Generate health reports, view trends | `analysis/analysis_screen.dart` |
| **Abnormalities** | Alert system for detected issues | `abnormalities/abnormalities_screen.dart` |
| **Education** | Cycle information, health tips | `education/cycle_info_screen.dart`, `education/tips_screen.dart` |
| **Settings** | User profile, preferences | `settings/settings_screen.dart` |
| **Navigation** | Bottom navigation, screen routing | `navigation/root_nav.dart` |

---

## Technology Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                       TECHNOLOGY STACK                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Frontend Framework:  Flutter (Dart)                               │
│  UI Framework:        Material Design 3                            │
│                                                                     │
│  Database:           SQLite (via sqflite)                          │
│  Path Management:    path_provider                                 │
│                                                                     │
│  Machine Learning:   TensorFlow Lite (tflite_flutter)              │
│  Model File:         mensus_multilabel_weighted.tflite             │
│                                                                     │
│  File Operations:   pdf (PDF generation)                           │
│                     share_plus (file sharing)                      │
│                                                                     │
│  Security:          crypto (data encryption)                       │
│  Development:       Flutter Lints, Integration Tests               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema

```
┌──────────────────────────────────────────────────────────────────┐
│                    DATABASE SCHEMA (SQLite)                      │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USERS TABLE                    │  PERIODS TABLE                │
│  ├─ id (PK)                     │  ├─ id (PK)                  │
│  ├─ userId (unique)             │  ├─ userId (FK)              │
│  ├─ email                       │  ├─ startDate                │
│  ├─ passwordHash                │  ├─ endDate                  │
│  ├─ dateOfBirth                 │  ├─ flow (intensity)         │
│  ├─ lastMenstrualDate           │  └─ notes                    │
│  └─ createdAt                   │                              │
│                                 │                              │
│  SYMPTOMS TABLE                 │  HEALTH_METRICS TABLE        │
│  ├─ id (PK)                     │  ├─ id (PK)                  │
│  ├─ userId (FK)                 │  ├─ userId (FK)              │
│  ├─ date                        │  ├─ date                     │
│  ├─ symptomType                 │  ├─ sleepHours               │
│  ├─ intensity (1-5)             │  ├─ weight                   │
│  ├─ notes                       │  ├─ exercise                 │
│  └─ createdAt                   │  └─ stress (1-5)             │
│                                 │                              │
│  ABNORMALITIES TABLE            │  PREDICTIONS TABLE           │
│  ├─ id (PK)                     │  ├─ id (PK)                  │
│  ├─ userId (FK)                 │  ├─ userId (FK)              │
│  ├─ date                        │  ├─ date                     │
│  ├─ abnormalityType             │  ├─ cyclePhase               │
│  ├─ severity                    │  ├─ abnormalityRisk          │
│  ├─ description                 │  ├─ confidence               │
│  └─ resolvedAt                  │  └─ details (JSON)           │
│                                 │                              │
└──────────────────────────────────────────────────────────────────┘
```

---

## ML Model Integration

```
┌──────────────────────────────────────────────────────────────────┐
│                  ML MODEL PIPELINE (TFLite)                      │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Model: mensus_multilabel_weighted.tflite                        │
│  ├─ Type: Multilabel Classification Model                        │
│  ├─ Purpose: Menstrual Health Abnormality Detection              │
│  └─ Location: assets/models/                                     │
│                                                                  │
│  INPUT FEATURES (from Preprocessing):                            │
│  ├─ Normalized symptom data                                      │
│  ├─ Period cycle phase                                           │
│  ├─ Health metrics (sleep, weight, etc.)                         │
│  ├─ Historical patterns                                          │
│  └─ Temporal features                                            │
│                                                                  │
│  OUTPUT PREDICTIONS:                                             │
│  ├─ Normal / Regular Cycle                                       │
│  ├─ Irregular Pattern                                            │
│  ├─ Abnormality Type:                                            │
│  │  ├─ Hormonal Imbalance                                        │
│  │  ├─ Severe Dysmenorrhea                                       │
│  │  ├─ PMS Symptoms                                              │
│  │  └─ Other Abnormalities                                       │
│  ├─ Severity Level (1-5)                                         │
│  └─ Confidence Score (0-1)                                       │
│                                                                  │
│  INFERENCE FLOW:                                                 │
│  1. Load Model ──▶ 2. Prepare Input ──▶ 3. Run Inference         │
│              ──▶ 4. Parse Output ──▶ 5. Post-process ──▶ 6. Store │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## User Journey Flowchart

```
┌─────────────┐
│   START     │
└──────┬──────┘
       │
       ▼
   ┌───────────┐        ┌─────────────┐
   │   Login   │───────▶│ Not Logged? │
   │           │        │ Go Register │
   └─────┬─────┘        └─────────────┘
         │
         ▼
   ┌──────────────┐
   │ Home Screen  │
   │ (Dashboard)  │
   └──────┬───────┘
          │
    ┌─────┴─────┬──────────┬──────────┬─────────────┐
    │            │          │          │             │
    ▼            ▼          ▼          ▼             ▼
 ┌─────┐  ┌─────────┐  ┌────────┐ ┌────────┐  ┌─────────┐
 │ Add │  │ Calendar│  │ Symptom│ │Reports │  │Education│
 │Sympt│  │ Tracker │  │History │ │ & Data │  │ & Tips  │
 └──┬──┘  └────┬────┘  └────┬───┘ └────┬───┘  └────┬────┘
    │          │            │          │           │
    │          │            │          │           │
    └──────────┬────────────┴──────────┴───────────┘
               │
               ▼
        ┌─────────────────┐
        │ Preprocessing   │
        │ & Validation    │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ ML Inference    │
        │ (TFLite Model)  │
        └────────┬────────┘
                 │
         ┌───────┴────────┐
         │                │
         ▼                ▼
    ┌─────────┐      ┌──────────┐
    │ Normal  │      │Abnormality│
    │ Cycle   │      │ Detected  │
    └────┬────┘      └────┬──────┘
         │                │
         └────────┬───────┘
                  │
                  ▼
        ┌───────────────────┐
        │ Display Results & │
        │ Predictions       │
        └────────┬──────────┘
                 │
                 ▼
         ┌──────────────┐
         │ Store in DB  │
         │ & Generate   │
         │ Alerts       │
         └────────┬─────┘
                  │
                  ▼
           ┌─────────────┐
           │ Share/Export│
           │ Report      │
           └─────────────┘
```

---

## Security & Data Privacy

```
┌─────────────────────────────────────────────────────────────────┐
│                  SECURITY ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AUTHENTICATION:                                                │
│  ├─ User ID & Password validation                              │
│  ├─ Password hashing (crypto package)                          │
│  └─ Session management                                         │
│                                                                 │
│  DATA STORAGE:                                                 │
│  ├─ Local SQLite database (on device)                          │
│  ├─ No cloud storage (privacy-first)                           │
│  ├─ Encrypted credentials storage                              │
│  └─ Sensitive data isolation                                   │
│                                                                 │
│  FILE SHARING:                                                 │
│  ├─ Share via share_plus (secure channels)                     │
│  ├─ PDF export with metadata control                           │
│  └─ User consent for sharing                                   │
│                                                                 │
│  MODEL SECURITY:                                               │
│  ├─ TFLite model bundled locally (no external calls)           │
│  ├─ No internet dependency for predictions                     │
│  └─ Privacy-preserving ML inference                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Deployment & Build Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    BUILD & DEPLOYMENT FLOW                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  SOURCE CODE                                                     │
│  (lib/ + pubspec.yaml)                                           │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────┐     ┌──────────────┐                       │
│  │ Flutter Build   │────▶│ Platform:    │                       │
│  │ Process         │     │ ├─ Android   │                       │
│  └────────┬────────┘     │ ├─ iOS       │                       │
│           │              │ ├─ Linux     │                       │
│           ▼              │ ├─ macOS     │                       │
│  ┌─────────────────┐     │ └─ Windows   │                       │
│  │ Asset Bundling  │     └──────────────┘                       │
│  │ ├─ Images       │                                             │
│  │ ├─ Models       │                                             │
│  │ └─ Fonts        │                                             │
│  └────────┬────────┘                                             │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────────┐                                        │
│  │ Platform-Specific    │                                        │
│  │ Build (APK/AAB)      │                                        │
│  └────────┬─────────────┘                                        │
│           │                                                      │
│           ▼                                                      │
│  ┌──────────────────────┐                                        │
│  │ Distribution         │                                        │
│  │ ├─ Play Store        │                                        │
│  │ ├─ TestFlight        │                                        │
│  │ └─ Direct Install    │                                        │
│  └──────────────────────┘                                        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Performance & Optimization

```
┌──────────────────────────────────────────────────────────────────┐
│              PERFORMANCE OPTIMIZATION STRATEGIES                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  UI PERFORMANCE:                                                 │
│  ├─ Stateful widgets for state management                        │
│  ├─ Lazy loading for list views                                  │
│  ├─ Responsive design (scale factors)                            │
│  └─ Material Design 3 optimizations                              │
│                                                                  │
│  DATABASE PERFORMANCE:                                           │
│  ├─ SQLite indexing on frequently queried columns                │
│  ├─ Connection pooling (sqflite)                                 │
│  ├─ Batch operations for bulk inserts                            │
│  └─ Query optimization                                           │
│                                                                  │
│  ML MODEL PERFORMANCE:                                           │
│  ├─ Quantized TFLite model (lightweight)                         │
│  ├─ On-device inference (no network latency)                     │
│  ├─ Model caching                                                │
│  └─ Async inference processing                                   │
│                                                                  │
│  MEMORY MANAGEMENT:                                              │
│  ├─ Proper disposal of controllers                               │
│  ├─ Image caching & optimization                                 │
│  ├─ Lazy initialization of services                              │
│  └─ Garbage collection optimization                              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Testing Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    TESTING ARCHITECTURE                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  UNIT TESTS (test/ directory)                                    │
│  ├─ preprocessing_test.dart                                      │
│  │  └─ Data normalization & validation tests                     │
│  ├─ database_service_test.dart                                   │
│  │  └─ CRUD operations & queries                                 │
│  └─ Widget_test.dart                                             │
│     └─ Widget rendering & interaction                            │
│                                                                  │
│  INTEGRATION TESTS (integration_test/)                            │
│  ├─ app_test.dart                                                │
│  └─ End-to-end user flow tests                                   │
│                                                                  │
│  TESTING TOOLS:                                                  │
│  ├─ flutter_test SDK                                             │
│  ├─ sqflite_common_ffi (SQLite testing)                           │
│  ├─ integration_test SDK                                         │
│  └─ flutter_lints (code quality)                                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## File Structure Overview

```
mensacare/
├── lib/
│   ├── main.dart                           (Entry point, Theme setup)
│   ├── services/                           (Business logic layer)
│   │   ├── database_service.dart          (SQLite CRUD operations)
│   │   ├── inference_service.dart         (ML model inference)
│   │   └── preprocessing.dart             (Data normalization)
│   └── features/                           (UI layer - organized by feature)
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home/
│       │   └── home_screen.dart
│       ├── navigation/
│       │   └── root_nav.dart
│       ├── calendar/
│       │   └── calendar_screen.dart
│       ├── symptoms/
│       │   ├── add_symptoms_screen.dart
│       │   └── symptoms_history_screen.dart
│       ├── predictions/
│       │   └── predictions_screen.dart
│       ├── analysis/
│       │   └── analysis_screen.dart
│       ├── abnormalities/
│       │   └── abnormalities_screen.dart
│       ├── education/
│       │   ├── cycle_info_screen.dart
│       │   └── tips_screen.dart
│       └── settings/
│           └── settings_screen.dart
├── assets/
│   ├── images/                            (UI images & icons)
│   └── models/
│       └── mensus_multilabel_weighted.tflite (ML model)
├── android/                                (Android platform code)
├── ios/                                    (iOS platform code)
├── test/                                   (Unit tests)
└── integration_test/                       (Integration tests)
```

---

## Key Design Patterns

```
┌──────────────────────────────────────────────────────────────────┐
│              ARCHITECTURAL DESIGN PATTERNS                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  LAYERED ARCHITECTURE:                                           │
│  ├─ Presentation Layer (Features)                                │
│  ├─ Service Layer (Business Logic)                               │
│  └─ Data Layer (Persistence)                                     │
│                                                                  │
│  SINGLETON PATTERN:                                              │
│  ├─ DatabaseService.instance                                     │
│  ├─ InferenceService.instance                                    │
│  └─ Ensures single instance of critical services                 │
│                                                                  │
│  REPOSITORY PATTERN:                                             │
│  ├─ Abstraction between business logic & data layer              │
│  ├─ Implemented in DatabaseService                               │
│  └─ Enables easy testing & maintenance                           │
│                                                                  │
│  MVC/MVVM VARIANTS:                                              │
│  ├─ StatefulWidget screens (Model + View)                        │
│  ├─ Service layer acts as controller/viewmodel                   │
│  └─ Separation of concerns                                       │
│                                                                  │
│  OBSERVER PATTERN:                                               │
│  ├─ Flutter's setState() for UI updates                          │
│  ├─ TextEditingController listeners                              │
│  └─ Stream-based state management potential                      │
│                                                                  │
│  FACTORY PATTERN:                                                │
│  ├─ Screen factories in navigation                               │
│  └─ Helps with route generation                                  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Summary

**MensaCare** is a comprehensive Flutter-based menstrual health tracking application with the following key characteristics:

- **Three-Layer Architecture**: Presentation (UI), Services (Business Logic), Data (Persistence)
- **Feature-Based Organization**: Each screen/feature is independent and modular
- **ML-Powered Predictions**: Integrated TensorFlow Lite model for abnormality detection
- **Local-First Privacy**: All data stored locally on device, no cloud dependency
- **Comprehensive Health Tracking**: Period, symptoms, metrics, and abnormality monitoring
- **Educational Content**: Built-in cycle information and health tips
- **Cross-Platform**: Deployable to Android, iOS, Windows, macOS, and Linux

The architecture emphasizes modularity, maintainability, privacy, and user-centric health insights through intelligent ML-powered analysis.

