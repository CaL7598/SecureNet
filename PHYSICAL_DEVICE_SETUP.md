# Physical Device Setup - Quick Guide

## 🚀 3-Step Setup for Physical Device

### Step 1: Find Your Computer's IP Address

**Windows:**
```bash
ipconfig
```
Look for **IPv4 Address** (e.g., `192.168.1.100`)

**macOS/Linux:**
```bash
ifconfig
# or
ip addr
```
Look for `inet` address (e.g., `192.168.1.100`)

### Step 2: Update API Configuration

Open `mobile-app/src/services/api.ts` and find this line:

```typescript
const PHONE_IP = '192.168.1.100'; // ⬅️ CHANGE THIS TO YOUR IP!
```

**Replace `192.168.1.100` with YOUR IP address**, then uncomment this line:

```typescript
// Change from:
return 'http://localhost:8000';

// To:
return `http://${PHONE_IP}:8000`;
```

Or simply change the `PHONE_IP` constant to your IP.

### Step 3: Test Connection

1. **Make sure backend is running:**
   ```bash
   cd backend
   uvicorn app.main:app --reload
   ```

2. **Test from your phone's browser:**
   Open: `http://YOUR_IP:8000/docs`
   - Should show API documentation ✅
   - If not, check firewall settings

3. **Start the app:**
   ```bash
   cd mobile-app
   npm start
   ```

4. **Scan QR code** with Expo Go app

## ✅ Verify It Works

1. Open app on phone
2. Go to Scan screen
3. Select "Demo Mode" (for testing)
4. Tap "Start Scan"
5. Should see results! 🎉

## 🔧 Troubleshooting

### "Network request failed"
- ✅ Both devices on same Wi-Fi?
- ✅ IP address correct?
- ✅ Backend running?
- ✅ Firewall blocking port 8000?

### "Connection refused"
- ✅ Check IP address is correct
- ✅ Backend is running (`uvicorn` command active)
- ✅ Try accessing `http://YOUR_IP:8000/docs` in phone browser

### Firewall Issues

**Windows:**
1. Open Windows Defender Firewall
2. Advanced Settings
3. Inbound Rules > New Rule
4. Port > TCP > 8000 > Allow

**macOS:**
1. System Preferences > Security & Privacy
2. Firewall > Firewall Options
3. Allow incoming connections for Python

## 📱 Quick Reference

**Your Setup:**
- Computer IP: `_________________`
- Backend URL: `http://__________:8000`
- Both on Wi-Fi: `_________________`

**Test URL (open in phone browser):**
```
http://YOUR_IP:8000/api/v1/health
```
Should return: `{"status":"healthy"}`

---

**That's it! You're ready to go! 🚀**
