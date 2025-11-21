# Money Heist Backend API

Express.js backend API for the Money Heist fintech application, powered by Supabase.

## 🚀 Quick Start

1. **Install dependencies:**
```bash
npm install
```

2. **Set up environment variables:**
Create a `.env` file in the `backend` directory:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PORT=5001
```

3. **Start development server:**
```bash
npm run dev
```

The API will be running at `http://localhost:5001`

## 📚 API Documentation

### Authentication Endpoints

#### Sign Up
```http
POST /api/auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": { ... },
  "session": { ... }
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": { ... },
  "session": {
    "access_token": "...",
    ...
  }
}
```

### Wallet Endpoints

All wallet endpoints require authentication via Bearer token in the Authorization header.

#### Get Wallet
```http
GET /api/wallet
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "balance": 1000.50,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

#### Deposit Money
```http
POST /api/wallet/deposit
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "amount": 500.00
}
```

#### Withdraw Money
```http
POST /api/wallet/withdraw
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "amount": 200.00
}
```

### Transaction Endpoints

#### Get Transactions
```http
GET /api/transactions
Authorization: Bearer <access_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "amount": 100.00,
    "type": "debit",
    "created_at": "2024-01-01T00:00:00Z"
  },
  ...
]
```

#### Process Payment (with auto-investment)
```http
POST /api/transactions/process-payment
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "amount": 500.00
}
```

**Response:**
```json
{
  "status": "success",
  "invested": 4.20
}
```

This endpoint:
1. Deducts the payment amount from wallet
2. Records a debit transaction
3. Calculates investment amount (1-10% based on rules)
4. Credits investment to wallet
5. Records an investment transaction

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── routes/           # Express route handlers
│   │   ├── auth.ts       # Authentication routes
│   │   ├── wallet.ts     # Wallet management routes
│   │   └── transactions.ts # Transaction routes
│   ├── services/         # Business logic layer
│   │   ├── auth.ts       # Auth service
│   │   ├── wallet.ts     # Wallet operations
│   │   ├── transactions.ts # Transaction operations
│   │   └── supabase.ts   # Supabase client
│   └── server.ts         # Express app setup
├── package.json
├── tsconfig.json
└── .env                  # Environment variables (not in git)
```

## 🔧 Development

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm test` - Run tests
- `npm run lint` - Lint code

### TypeScript

The project uses TypeScript for type safety. Configuration is in `tsconfig.json`.

## 🔒 Security

- All wallet and transaction endpoints require authentication
- Passwords are hashed by Supabase Auth
- Environment variables are used for sensitive data
- CORS is enabled for frontend communication

## 📊 Database Schema

The backend expects the following Supabase tables:

- `wallet` - User wallet balances
- `transactions` - Transaction history
- `auth.users` - User authentication (managed by Supabase)

See the main README for SQL schema definitions.

## 🐛 Error Handling

All endpoints return appropriate HTTP status codes:
- `200` - Success
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid token)
- `404` - Not Found
- `500` - Internal Server Error

Error responses follow this format:
```json
{
  "error": "Error message here"
}
```

## 🚢 Deployment

1. Build the project:
```bash
npm run build
```

2. Set environment variables on your hosting platform

3. Start the server:
```bash
npm start
```

Recommended hosting platforms:
- **Railway** - Easy deployment with automatic HTTPS
- **Render** - Free tier available
- **Heroku** - Classic platform
- **DigitalOcean App Platform** - Simple and scalable

