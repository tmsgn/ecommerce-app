# SHOPEASE — Mobile E-Commerce App

**Group 7 | Mobile App Development Assignment**  
**Bahir Dar University — Department of Computer Science**

---

## 👥 Group Members

| # | Student ID   | First Name   | Last Name  |
|---|--------------|--------------|------------|
| 1 | BDU1602534   | Temesgen     | Tarekegn   |
| 2 | BDU1602667   | Wintana      | Girma      |
| 3 | BDU1602708   | Yalemzewud   | Tenaw      |
| 4 | BDU1602761   | Yetmwork     | Lakachew   |
| 5 | BDU1602875   | Yordanos     | Tsehay     |
| 6 | BDU1602881   | Yosef        | Tadesse    |
| 7 | BDU1602880   | Yosef        | Melaku     |
| 8 | BDU1602906   | Zelalem      | Ybabe      |

---

## 📱 App Overview

SHOPEASE is a full-featured, premium Android e-commerce application built with **Flutter** and **Firebase**. It provides a modern, dark-themed shopping experience with complete auth, product browsing, cart, wishlist, checkout, and order tracking.

---

## ✨ Features

- 🔐 **Authentication** — Email/password + Google Sign-In via Firebase Auth
- 🛍️ **Product Catalog** — Browse 16+ products across 6 categories
- 🔍 **Search** — Real-time product search
- 🏷️ **Categories** — Filter by Electronics, Fashion, Beauty, Sports, Toys, Home & Living
- 🛒 **Cart** — Add, update quantity, remove items, persistent via Firestore
- ❤️ **Wishlist** — Save favourite products
- 💳 **Checkout** — Order placement with delivery address
- 📦 **Orders** — Track order history and status
- 👤 **Profile** — Edit name, theme toggle (dark/light), settings
- 🌙 **Dark/Light Mode** — Full theme support

---

## 🛠️ Tech Stack

| Layer       | Technology                  |
|-------------|------------------------------|
| UI          | Flutter (Dart)               |
| Auth        | Firebase Authentication      |
| Database    | Cloud Firestore              |
| State       | Provider                     |
| Images      | cached_network_image         |
| Fonts       | Google Fonts (Outfit + Inter)|
| Splash      | flutter_native_splash        |
| Icons       | flutter_launcher_icons       |

---

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── firebase_options.dart  # Firebase config
├── pages/                 # UI screens
│   ├── auth.dart          # Auth gate + splash
│   ├── home.dart          # Home/product listing
│   ├── login.dart         # Login screen
│   ├── register.dart      # Registration
│   ├── profile.dart       # User profile & About
│   ├── cart.dart          # Shopping cart
│   ├── wishlist.dart      # Wishlist
│   ├── checkout.dart      # Checkout flow
│   ├── orders.dart        # Order history
│   ├── product_detail.dart# Product details
│   └── categories.dart    # Category browser
├── services/
│   ├── firestore_service.dart  # All Firestore operations
│   └── google_auth_service.dart
├── models/                # Data models
├── providers/             # State management
├── themes/                # Light & dark themes
└── components/            # Reusable widgets
```

---

*Built with ❤️ by Group 7 — Bahir Dar University*