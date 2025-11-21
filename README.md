# Money Heist 💰

A modern fintech application that combines UPI payments with automatic investment features. Built with Flutter for the mobile frontend and Node.js/Express with Supabase for the backend.

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- Flutter 3.24+
- Supabase account

### 1. Database Setup (REQUIRED FIRST STEP)

**Before running the app, set up your Supabase database:**

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and run the entire SQL script from `backend/database_setup_simple.sql`
   - **Use the simple version** (no triggers) to avoid signup errors
   - Or use `backend/database_setup.sql` if you prefer triggers (may cause issues)

This creates:
- `wallet` and `transactions` tables
- Row Level Security (RLS) policies
- Indexes for performance
- Wallet is created automatically on first login/wallet access

### 2. Backend Setup

```bash
cd backend
npm install

# Create .env file with:
# SUPABASE_URL=your_supabase_url
# SUPABASE_ANON_KEY=your_supabase_anon_key
# PORT=5001

npm run dev
```

Backend will run on `http://localhost:5001`

### 3. Frontend Setup

```bash
cd frontend
flutter pub get

# Create .env file with:
# API_BASE_URL=http://localhost:5001
# (For Android emulator: http://10.0.2.2:5001)

flutter run
```

## 📁 Project Structure

```
money_heist/
├── backend/
│   ├── src/
│   │   ├── routes/          # API endpoints
│   │   ├── services/         # Business logic
│   │   └── server.ts        # Express server
│   ├── database_setup.sql   # Database schema
│   └── package.json
│
├── frontend/
│   ├── lib/
│   │   ├── screens/         # UI screens
│   │   ├── services/        # API client & repositories
│   │   └── providers/      # State management
│   └── pubspec.yaml
│
└── README.md
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/signup` - Create account
- `POST /api/auth/login` - Login

### Wallet
- `GET /api/wallet` - Get balance (requires auth)
- `POST /api/wallet/deposit` - Add money
- `POST /api/wallet/withdraw` - Withdraw money

### Transactions
- `GET /api/transactions` - Get history (requires auth)
- `POST /api/transactions/process-payment` - Process payment with auto-investment

## 💡 Features

- **User Authentication** - Secure signup/login with Supabase
- **UPI Payments** - QR scan or phone number payments
- **Auto-Investment** - 1-10% automatic investment on payments
- **Wallet Management** - Track balance and transactions
- **Biometric Security** - Fingerprint/Face ID support

## 🧪 Testing

### Test Backend
```bash
# Health check
curl http://localhost:5001/health

# Signup
curl -X POST http://localhost:5001/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Test Frontend
1. Start backend: `cd backend && npm run dev`
2. Start Flutter: `cd frontend && flutter run`
3. Try signup/login in the app

## 🐛 Troubleshooting

**"Database error saving new user"**
- Run `backend/database_setup.sql` in Supabase SQL Editor
- Check Supabase Auth is enabled

**"Connection refused"**
- Ensure backend is running
- Check API_BASE_URL in frontend/.env
- For Android emulator, use `http://10.0.2.2:5001`

**"Invalid credentials"**
- Check email/password format
- Verify user exists (try signup first)

## 📝 Environment Variables

**backend/.env:**
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PORT=5001
```

**frontend/.env:**
```
API_BASE_URL=http://localhost:5001
```

## 🚀 Deployment

### Backend
1. Build: `npm run build`
2. Deploy to Railway/Render/Heroku
3. Set environment variables

### Frontend
1. Build: `flutter build apk` (Android) or `flutter build ios` (iOS)
2. Publish to app stores

## 📄 License

MIT License

---

**Important**: Always run `backend/database_setup.sql` in Supabase before first use!
