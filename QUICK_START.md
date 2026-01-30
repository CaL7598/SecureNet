# SecureNet Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Start Backend

```bash
cd backend

# Start PostgreSQL
docker-compose up -d

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Seed database
python scripts/seed_data.py

# Start API server
uvicorn app.main:app --reload
```

✅ Backend running at http://localhost:8000

### Step 2: Test Backend

```bash
# In another terminal
cd backend
python test_api.py
```

### Step 3: Start Mobile App

```bash
cd mobile-app

# Install dependencies
npm install

# Start Expo
npm start
```

✅ Scan QR code with Expo Go app or run on simulator

### Step 4: Test the App

1. Open the app
2. Select **"Demo Mode"** (for testing)
3. Tap **"Start Scan"**
4. View results!

## 📱 Testing Options

### Demo Mode (Recommended for Testing)
- No network access required
- Uses mock vulnerability data
- Perfect for UI testing

### Real Network Scan
- Requires native modules setup
- Needs network permissions
- See [NATIVE_MODULES.md](docs/NATIVE_MODULES.md) for setup

## 🔧 Troubleshooting

### Backend Issues
- **Port 8000 in use?** Change port: `uvicorn app.main:app --reload --port 8001`
- **Database connection failed?** Check Docker: `docker ps`
- **Import errors?** Ensure virtual environment is activated

### Mobile App Issues
- **Can't connect to API?** 
  - iOS Simulator: Use `localhost`
  - Android Emulator: Use `10.0.2.2`
  - Physical device: Use your computer's IP address
- **Module not found?** Run `npm install` again
- **Build errors?** Clear cache: `npm start -- --reset-cache`

## 📚 Next Steps

- Read [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed setup
- Check [API.md](docs/API.md) for API documentation
- Review [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for architecture

## 🎯 What's Working

✅ Backend API with vulnerability analysis  
✅ Mobile app UI matching design  
✅ Demo mode for testing  
✅ Scan history persistence  
✅ Settings management  
✅ Error handling  

## 🚧 What Needs Native Modules

⚠️ Real network scanning (ARP table access)  
⚠️ Port scanning (TCP connections)  
⚠️ Network topology detection  

See [NATIVE_MODULES.md](docs/NATIVE_MODULES.md) for implementation guide.

---

**Ready to build! 🎉**
