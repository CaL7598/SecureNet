# Scan Not Working - Troubleshooting Guide

## Issue: Nothing Shows After Clicking Scan

### Quick Checks

1. **Is the backend running?**
   ```bash
   # Check if backend is running
   curl http://localhost:8000/api/v1/health
   ```
   Should return: `{"status":"healthy"}`

2. **Check browser console (F12)**
   - Look for error messages
   - Check Network tab for failed API calls

3. **Verify you're in Demo Mode**
   - On Scan screen, make sure "Demo Mode" is selected (right toggle)
   - Demo mode doesn't require backend

### Common Issues

#### 1. Backend Not Running
**Symptom:** Error in console about connection refused or network error

**Solution:**
```bash
# Terminal 1: Start backend
cd backend
uvicorn app.main:app --reload
```

#### 2. CORS Error
**Symptom:** CORS policy error in console

**Solution:** Backend should allow CORS. Check `backend/app/main.py` has CORS middleware.

#### 3. Navigation Not Working
**Symptom:** Scan completes but screen doesn't change

**Solution:** 
- Check browser console for navigation errors
- Try refreshing the page
- Check if Results screen is properly registered in navigation

#### 4. API Timeout
**Symptom:** Request times out after 30 seconds

**Solution:**
- Check backend is responding: `curl http://localhost:8000/api/v1/health`
- Increase timeout in `mobile-app/src/services/api.ts`

### Debug Steps

1. **Open browser console (F12)**
2. **Click "Start Scan"**
3. **Look for console logs:**
   - "Sending devices to API: ..."
   - "Received analysis: ..."
   - "Navigating to Results screen..."

4. **Check Network tab:**
   - Look for request to `/api/v1/analyze-network`
   - Check status code (should be 200)
   - Check response data

### Quick Fix: Use Demo Mode

If backend isn't running, use Demo Mode:
1. On Scan screen
2. Select "Demo Mode" (right toggle)
3. Click "Start Scan"
4. Should work without backend

### Still Not Working?

1. **Share browser console errors**
2. **Check if backend is running:**
   ```bash
   curl http://localhost:8000/api/v1/health
   ```
3. **Try demo mode first** to verify UI works
4. **Check network tab** for API calls
