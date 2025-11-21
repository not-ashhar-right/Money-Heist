# Money Heist Flutter App

Flutter mobile application for the Money Heist fintech platform.

## 🚀 Quick Start

1. **Install Flutter dependencies:**
```bash
flutter pub get
```

2. **Set up environment variables:**
Create a `.env` file in the `frontend` directory:
```env
API_BASE_URL=http://localhost:5001
```

**Important**: For different platforms, use:
- **Android Emulator**: `http://10.0.2.2:5001`
- **iOS Simulator**: `http://localhost:5001`
- **Physical Device**: `http://<your-computer-ip>:5001` (e.g., `http://192.168.1.100:5001`)

3. **Run the app:**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 📱 Features

- **Authentication**: Sign up and login with email/password
- **Biometric Security**: Fingerprint/Face ID authentication
- **UPI Payments**: Scan QR codes or pay by phone number
- **Wallet Management**: View balance and transaction history
- **Auto-Investment**: Automatic investment on each payment
- **Real-time Updates**: Live wallet balance updates

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                 # UI screens
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── wallet_screen.dart
│   ├── upi_payment_screen.dart
│   └── ...
├── services/                # API integration
│   ├── api_client.dart      # HTTP client
│   ├── auth_repository.dart # Auth operations
│   └── wallet_repository.dart # Wallet operations
└── providers/               # State management
    ├── session_provider.dart
    └── wallet_provider.dart
```

## 🔌 API Integration

The app communicates with the backend API through:

- **ApiClient**: Handles all HTTP requests
- **AuthRepository**: Manages authentication state
- **WalletRepository**: Handles wallet and transaction operations

All API calls are authenticated using secure token storage.

## 🎨 UI/UX

- **Dark Theme**: Modern dark green gradient theme
- **Material Design 3**: Latest Material Design components
- **Responsive**: Works on phones and tablets
- **Smooth Animations**: Polished user experience

## 📦 Dependencies

Key packages used:
- `provider` - State management
- `http` - API requests
- `flutter_secure_storage` - Secure token storage
- `flutter_dotenv` - Environment variables
- `local_auth` - Biometric authentication

## 🔐 Security

- Tokens stored securely using `flutter_secure_storage`
- HTTPS recommended for production
- Biometric authentication for app access
- Input validation on all forms

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🐛 Troubleshooting

### API Connection Issues

1. **Android Emulator**: Use `http://10.0.2.2:5001` instead of `localhost`
2. **Physical Device**: Ensure your device and computer are on the same network
3. **CORS Errors**: Make sure backend CORS is configured correctly

### Build Issues

1. Clean build:
```bash
flutter clean
flutter pub get
```

2. Check Flutter version:
```bash
flutter --version
```

## 📝 Environment Variables

The app uses `flutter_dotenv` to load environment variables from `.env` file. Make sure to:

1. Create `.env` file in the `frontend` directory
2. Add `API_BASE_URL` variable
3. Never commit `.env` to version control

## 🚀 Deployment

### Google Play Store
1. Build app bundle: `flutter build appbundle`
2. Upload to Google Play Console
3. Complete store listing and submit for review

### Apple App Store
1. Build iOS app: `flutter build ios`
2. Archive in Xcode
3. Upload to App Store Connect
4. Submit for review

### Web
1. Build web: `flutter build web`
2. Deploy `build/web` folder to hosting (Firebase Hosting, Netlify, etc.)

## 📧 Support

For issues or questions, please open an issue in the repository.

