# API Configuration for Physical Devices

## Quick Setup

When running the app on a **physical device**, you need to configure the API URL to use your computer's IP address instead of `localhost`.

### Step 1: Find Your Computer's IP Address

#### Windows:
```bash
ipconfig
```
Look for **IPv4 Address** under your active network adapter (usually WiFi or Ethernet).
Example: `192.168.1.100`

#### macOS/Linux:
```bash
ifconfig
# or
ip addr
```
Look for `inet` address (usually starts with `192.168.x.x` or `10.x.x.x`).

### Step 2: Update API Configuration

Edit `mobile-app/src/services/api.ts`:

```typescript
// Replace this line:
const DEV_API_URL = __DEV__ 
  ? Platform.OS === 'android'
    ? 'http://10.0.2.2:8000'
    : Platform.OS === 'ios'
    ? 'http://localhost:8000'
    : 'http://localhost:8000'
  : 'https://api.securenet.app';

// With your IP address:
const DEV_API_URL = 'http://192.168.1.100:8000'; // Use YOUR IP address
```

### Step 3: Make Sure Backend is Accessible

1. **Check Firewall**: Your computer's firewall might block port 8000
   - Windows: Allow port 8000 in Windows Firewall
   - macOS: System Preferences > Security & Privacy > Firewall

2. **Check Network**: Both devices must be on the same Wi-Fi network

3. **Test Connection**: From your phone's browser, try:
   ```
   http://YOUR_IP:8000/api/v1/health
   ```
   Should return: `{"status":"healthy"}`

### Step 4: Restart the App

After changing the API URL:
```bash
# In mobile-app directory
npm start -- --reset-cache
```

## Alternative: Environment Variable (Recommended)

For easier configuration, you can use an environment variable:

1. Create `.env` file in `mobile-app/`:
```
API_BASE_URL=http://192.168.1.100:8000
```

2. Install `react-native-dotenv`:
```bash
npm install react-native-dotenv
```

3. Update `api.ts` to use the environment variable

## Troubleshooting

### "Network request failed"
- ✅ Check IP address is correct
- ✅ Verify both devices on same Wi-Fi
- ✅ Check firewall settings
- ✅ Ensure backend is running (`uvicorn app.main:app --reload`)

### "Connection refused"
- ✅ Backend might not be running
- ✅ Wrong IP address
- ✅ Port 8000 blocked by firewall

### "Timeout"
- ✅ Check network connection
- ✅ Verify backend is accessible from phone browser
- ✅ Try increasing timeout in `api.ts`

## Quick Test

1. Find your IP: `ipconfig` or `ifconfig`
2. Open phone browser: `http://YOUR_IP:8000/docs`
3. Should see API documentation
4. If yes, update `api.ts` with your IP
5. Restart app!
