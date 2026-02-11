# BoostDrive Ecosystem 🏎️💨

BoostDrive is a premium, all-in-one automotive lifecycle ecosystem specifically tailored for the Namibian market. It bridges the gap between emergency roadside services and high-end automotive marketplace solutions, providing a seamless experience for vehicle owners, renters, and service providers.

## 🌟 Overview

The ecosystem consists of two flagship applications and a suite of shared infrastructure packages, built on a robust Flutter monorepo architecture. 

- **BoostDrive Com (Mobile App)**: A mobile-first, location-aware platform focused on driver safety and roadside assistance.
- **BoostDrive Shop (Web App)**: A premium marketplace for spare parts, car rentals, and luxury vehicle sales.

---

## 🛠️ Tech Stack & Rationale

| Technology | Usage | Rationale |
| :--- | :--- | :--- |
| **Flutter** | Frontend (Cross-platform) | Single codebase for iOS, Android, Web, and Windows, ensuring rapid feature parity and premium UI performance. |
| **Firebase** | Backend-as-a-Service | Real-time capabilities for SOS tracking, industry-standard authentication, and serverless scalability. |
| **Riverpod** | State Management | Ensures a predictable, testable, and loosely coupled logic layer across all applications. |
| **Melos** | Monorepo Management | Orchestrates multiple packages and apps, standardizing scripts and dependency management. |
| **Firestore** | Database | A NoSQL real-time document store perfect for dynamic marketplace listings and emergency logging. |

---

## 🏗️ Architecture

BoostDrive uses a **Layered Monorepo Architecture** to maximize code reuse and maintainability.

### Project Structure (Packages)

- **`apps/Mobile`**: The primary flutter app for mobile users. Includes SOS persistence, live location tracking, and emergency dialers.
- **`apps/Web`**: The marketplace platform with a premium responsive layout, advanced filtering, and booking systems.
- **`packages/boostdrive_ui`**: The "Source of Truth" for the design system. Contains shared widgets, HSL-based color tokens, and global layout wrappers.
- **`packages/boostdrive_services`**: Encapsulates business logic, Firestore integrations, and provider-based services (Product, SOS, Cart, Booking).
- **`packages/boostdrive_core`**: Contains platform-neutral models (Product, UserProfile) and shared constants.
- **`packages/boostdrive_firebase`**: Centralizes Firebase configuration and handles cross-platform Authentication complexities (including Web reCAPTCHA stubs).

---

## 🚀 Key Features

### Mobile Services Platform
- **One-Tap SOS**: Instantly broadcasts emergency requests to Firestore with precise GPS coordinates.
- **Location Persistence**: Uses background-friendly tracking to ensure help can always find you.
- **Emergency Dialers**: Direct links to Police and Ambulance services with platform-native fallbacks.
- **Global Backgrounding**: A consistent, immersive dark-themed experience across all pages.

### Web Marketplace Platform
- **Premium Shop Experience**: Sophisticated grid-based browsing for auto parts and car rentals.
- **Cross-Platform Auth**: Unified login using Firebase Phone Auth, optimized for both Web (reCAPTCHA v3/v2) and Mobile.
- **Dynamic Listings**: Real-time listing updates with integrated Firestore persistence.
- **Responsive Layouts**: Optimized for desktop viewing while maintaining mobile-ready accessibility.

---

## 💻 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.x or higher)
- [Melos](https://melos.invertase.dev/) (`dart pub global activate melos`)

### 📦 Installation

1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd BoostDrive
   ```

2. **Bootstrap the project**:
   This will link all local packages and fetch dependencies for all apps at once.
   ```bash
   melos bootstrap
   ```

3. **Verify Configuration**:
   Ensure `apps/Mobile/lib/firebase_options.dart` is present and configured with your Firebase Project keys.

---

## 🏃 Running the Application

### 📱 Mobile App (Android/iOS/Web)
To run the services platform:
```bash
cd apps/Mobile
flutter run -d chrome  # Run on Web (Chrome)
flutter run -d <device_id> # Run on physical device/emulator
```

### 💻 Web App (Marketplace)
To run the marketplace:
```bash
cd apps/Web
flutter run -d chrome
```

### 🛠️ Common Commands (Melos)
- **Run pub get on all packages**: `melos run get`
- **Run all tests**: `melos run test`
- **Clean all projects**: `melos run clean`

---

## 📄 Documentation & Schema
Detailed documentation files can be found in the `docs` directory (if available) or the brain artifacts:
- **Database Schema**: Refer to `database_schema.md`
- **Testing Guide**: Refer to `testing_guide.md`
- **Deployment Plan**: Refer to `deployment_plan.md`

Built with ❤️ by the BoostDrive Engineering Team.
