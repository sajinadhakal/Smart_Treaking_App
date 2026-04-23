# Socket Exception Login Fix - Complete Guide

## Problem Summary
**Socket exceptions and login failures on phone for 5 months** were caused by:
1. ❌ **Hardcoded IP mismatch** - App had `192.168.1.6` but your current IP is `192.168.1.3`
2. ❌ **No timeout handling** - Socket requests hung indefinitely
3. ❌ **Poor error messages** - Users couldn't debug connection issues

## Solution Applied ✅

### 1. Fixed IP Configuration
**File**: `front_end/lib/config/api_config.dart`

Changed:
```dart
// ❌ OLD - Hardcoded wrong IP
static const String _lanBaseUrl = 'http://192.168.1.6:8000/api';
```

To:
```dart
// ✅ NEW - Correct IP
static const String _deviceLocalIp = '192.168.1.3';
static const String _lanBaseUrl = 'http://$_deviceLocalIp:8000/api';
```

**How to update when your IP changes:**
1. Run `ipconfig` in PowerShell
2. Find IPv4 Address (e.g., `192.168.x.x`)
3. Update `_deviceLocalIp = '192.168.x.x'` in api_config.dart
4. Rebuild the Flutter app

### 2. Added Timeout & Error Handling
**File**: `front_end/lib/services/auth_service.dart`

✅ Added 10-second timeout to prevent hanging
✅ Better error messages showing the backend URL to connect to
✅ Handles socket exceptions gracefully

## Step-by-Step to Get It Working

### Step 1: Get Your Machine's Current IP
```powershell
ipconfig
```
Look for **IPv4 Address** under your WiFi adapter (usually `192.168.x.x`)

### Step 2: Verify Backend is Running
```powershell
# In the workspace directory
./run-backend.ps1
```

You should see:
```
Starting development server at http://192.168.x.x:8000
```

### Step 3: Ensure Phone is on Same WiFi
- Open phone WiFi settings
- Connect to the same WiFi network as your laptop
- DO NOT use mobile data or a different network

### Step 4: Find Backend URL
From backend output above, the URL format is:
```
http://192.168.x.x:8000/api
```

### Step 5: Rebuild Flutter App (if IP changed)
```powershell
cd front_end

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Step 6: Try Login
Use credentials:
- **Username**: `user` or any test username
- **Password**: `pass123` or your registered password

## Common Issues & Solutions

### Issue 1: "Socket Error: Connection timeout"
**Cause**: Backend not responding
**Solution**:
1. Check if backend is running: `./run-backend.ps1`
2. Verify IP in api_config.dart matches your machine IP
3. Ping the backend IP from phone: Open browser → `http://192.168.x.x:8000`

### Issue 2: Phone Can't Reach Backend
**Cause**: Different networks or firewall
**Solution**:
1. Phone must be on SAME WiFi as laptop
2. Disable phone's mobile data (use WiFi only)
3. Check Windows Firewall allows port 8000:
   ```powershell
   # Windows Firewall might block Django
   # Try: Settings → Windows Defender Firewall → Allow app through firewall
   # Add Python to allowed apps
   ```

### Issue 3: "Invalid credentials" after timeout fix
**Cause**: Socket fix working, but login data incorrect
**Solution**:
1. First verify backend is accessible: `http://192.168.x.x:8000/admin/`
2. Check if user exists in database
3. Try mock mode for testing:
   ```dart
   // In api_config.dart
   static const bool useMockData = true;  // Use mock logins
   ```

### Issue 4: IP Address Keeps Changing
**Solution**: Use a fixed IP for your laptop
1. Open Router admin (usually `192.168.1.1`)
2. Set static IP for your laptop's MAC address
3. Or use hostname instead:
   ```dart
   static const String _deviceLocalIp = 'your-laptop-name.local';
   ```

## Verification Checklist

- [ ] Backend running: `./run-backend.ps1`
- [ ] IP in api_config.dart matches current machine IP
- [ ] Phone on same WiFi (check mobile data is OFF)
- [ ] Can ping backend from phone browser: `http://192.168.x.x:8000`
- [ ] Flutter app rebuilt after IP change: `flutter clean && flutter pub get`
- [ ] Login shows proper error message (not socket hang)
- [ ] Login attempts update the UI quickly (no freezing)

## Additional Notes

### Why This Took 5 Months to Debug
- Hardcoded IPs are fragile - they change when network configuration changes
- No timeout meant the app would hang indefinitely
- No clear error messages meant users thought it was broken
- **Lesson**: Always use configurable endpoints or dynamic discovery

### Quick URL for Testing Backend Connectivity
```
Navigate from phone browser:
http://192.168.x.x:8000/api/destinations/
```
Should show JSON data if backend is working

### Enable Mock Mode for Testing Without Backend
```dart
// File: front_end/lib/config/api_config.dart
static const bool useMockData = true;
```
Then all login attempts will use test data (no backend needed)

## Still Having Issues?

1. Share the exact error message from login screen
2. Run: `ipconfig` and tell me the IPv4 Address
3. Check if `./run-backend.ps1` shows any errors
4. Try accessing backend in browser: `http://192.168.x.x:8000/api/`
