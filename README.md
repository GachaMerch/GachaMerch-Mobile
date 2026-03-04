# GachaMerch

Mobile app untuk platform gacha merchandise — beli, koleksi, dan kelola item langka dengan sistem rarity berbasis gacha.

Built with **Flutter** · Dart SDK `^3.8.1`

---

## Features

- **Shop** — browse item berdasarkan rarity & harga, beli langsung atau lewat sistem gacha
- **Inventory** — lihat koleksi item yang sudah dimiliki
- **Weapon Detail** — halaman detail tiap item/weapon
- **Notifications** — notifikasi transaksi dan update
- **Profile** — manajemen akun pengguna
- **Admin Panel** — kelola item (tambah, edit, hapus) khusus role admin
- **Auth** — login via email/password dan Google Sign-In
- **Dark / Light Mode** — adaptive theme, default dark

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.8.1`
- Android emulator / physical device

### Setup

```bash
# Install dependencies
flutter pub get

# Run app (development)
flutter run

# Build APK
flutter build apk --release
```

### Environment

API base URL dikonfigurasi di masing-masing service file:

```dart
// Release
'https://gachamerch-be.drian.my.id'

// Debug (Android emulator)
'http://10.0.2.2:3000'
```

---

## Project Structure

```
lib/
├── main.dart               # Entry point + AuthGate
├── LoginPage.dart
├── SignUpPage.dart
├── HomePage.dart
├── ShopPage.dart
├── InventoryPage.dart
├── WeaponDetailPage.dart
├── NotificationPage.dart
├── ProfilePage.dart
├── AboutUsPage.dart
├── services/               # API calls
│   ├── auth_service.dart
│   ├── shop_service.dart
│   ├── inventory_service.dart
│   ├── weapon_service.dart
│   ├── order_service.dart
│   └── notification_service.dart
├── widgets/                # Reusable components
└── utils/                  # Helpers (format, etc.)
```
