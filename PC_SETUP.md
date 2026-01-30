# Running SecureNet on PC - Quick Guide

## 🌐 Easiest Way: Web Browser

### Step 1: Start Backend
```bash
cd backend
uvicorn app.main:app --reload
```

### Step 2: Start Web App
```bash
cd mobile-app
npm run web
```

**That's it!** The app opens automatically in your browser at `http://localhost:19006`

---

## 📱 Full Experience: Android Emulator

### Setup (First Time Only):

1. **Install Android Studio**: https://developer.android.com/studio

2. **Create Emulator**:
   - Open Android Studio
   - Tools > Device Manager
   - Create Virtual Device
   - Choose a device (e.g., Pixel 5)
   - Download and select a system image
   - Finish

3. **Start Emulator**:
   - Click ▶️ Play button in Device Manager

### Run App:

```bash
cd mobile-app
npm run android
```

App automatically installs and runs on emulator!

---

## ✅ What Works Where

| Feature | Web Browser | Android Emulator | iOS Simulator |
|---------|-------------|------------------|---------------|
| UI Screens | ✅ | ✅ | ✅ |
| Navigation | ✅ | ✅ | ✅ |
| Demo Mode | ✅ | ✅ | ✅ |
| Settings | ✅ | ✅ | ✅ |
| History | ✅ | ✅ | ✅ |
| API Calls | ✅ | ✅ | ✅ |
| Real Network Scan | ❌ | ✅* | ✅* |

*Requires native modules to be registered

---

## 🚀 Recommended: Start with Web

For quick testing and development:

```bash
# Terminal 1
cd backend && uvicorn app.main:app --reload

# Terminal 2  
cd mobile-app && npm run web
```

**Benefits:**
- ✅ Fastest startup
- ✅ No emulator needed
- ✅ Easy debugging
- ✅ All UI features work
- ✅ Perfect for development

---

## 🔧 Troubleshooting

### Web Mode Issues

**"Cannot find module 'expo'"**
```bash
npm install
```

**Port 19006 in use?**
```bash
# Expo will automatically use next available port
# Or kill the process using port 19006
```

### Android Emulator Issues

**Emulator won't start?**
- Check Android Studio is installed
- Verify emulator is created in Device Manager
- Try restarting Android Studio

**App won't install?**
```bash
# Clear cache and try again
npm start -- --reset-cache
```

---

## 💡 Pro Tips

1. **Web mode is fastest** for UI development
2. **Use emulator** when testing native features
3. **Keep backend running** in separate terminal
4. **Hot reload works** in all modes - just save files!

---

**Ready to go! Just run `npm run web` and start coding! 🎉**
