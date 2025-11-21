import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { authRouter } from './routes/auth';
import { walletRouter } from './routes/wallet';
import { transactionRouter } from './routes/transactions';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRouter);
app.use('/api/wallet', walletRouter);
app.use('/api/transactions', transactionRouter);

app.listen(PORT, () => {
  console.log(`🚀 Money Heist API server running on port ${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}/health`);
});

