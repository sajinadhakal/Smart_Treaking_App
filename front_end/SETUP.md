# Flutter Frontend Setup Guide

## Prerequisites

### 1. Install Flutter SDK

**Download Flutter**:
- Visit: https://docs.flutter.dev/get-started/install/windows
- Download Flutter SDK for Windows
- Extract to `C:\flutter` (or your preferred location)

**Add to PATH**:
1. Search "Environment Variables" in Windows
2. Edit "Path" in System Variables
3. Add: `C:\flutter\bin`
4. Click OK

**Verify Installation**:
```powershell
flutter --version
flutter doctor
```

### 2. Install Android Studio (Recommended)

**Download**:
- Visit: https://developer.android.com/studio
- Download and install Android Studio

**Setup Android SDK**:
- Open Android Studio
- Go to Settings → Appearance & Behavior → System Settings → Android SDK
- Install latest Android SDK
- Install Android SDK Command-line Tools
- Install Android Emulator (optional)

**Accept Licenses**:
```powershell
flutter doctor --android-licenses
```

Press 'y' to accept all licenses.

### 3. Install VS Code (Alternative)

If using VS Code instead of Android Studio:
1. Install VS Code: https://code.visualstudio.com/
2. Install Flutter extension
3. Install Dart extension

## Setup Steps

### 1. Navigate to Frontend Directory

```powershell
cd C:\Users\sazna\6th_sem\front_end
```

### 2. Install Dependencies

```powershell
flutter pub get
```

This downloads all required packages:
- flutter_map (for OpenStreetMap)
- http, dio (for API calls)
- provider (state management)
- shared_preferences (local storage)
- And more...

### 3. Verify Installation

```powershell
flutter doctor
```

Check that all items show ✓ (or at least Android toolchain).

### 4. Configure API Endpoint

The app now picks up the backend URL from `front_end/run-app.ps1`, which detects your current LAN IP automatically.

If you launch Flutter directly from the IDE, set `API_BASE_URL` to your current machine IP, for example `http://192.168.1.4:8000/api`.

### 5. Connect Your Android Phone

#### Method 1: USB Debugging

1. **Enable Developer Mode**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging**:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect Phone**:
   - Connect phone to PC via USB
   - Phone will ask to "Allow USB debugging"
   - Check "Always allow" and tap OK

4. **Verify Connection**:
   ```powershell
   flutter devices
   ```
   
   You should see your phone listed.

#### Method 2: WiFi Debugging (Same Network)

1. First connect via USB (follow steps above)

2. **Get Phone IP**:
   - On phone: Settings → About Phone → Status → IP Address
   - Example: 192.168.1.15

3. **Enable TCP/IP Mode**:
   ```powershell
   adb tcpip 5555
   ```

4. **Connect Wirelessly**:
   ```powershell
   adb connect 192.168.1.15:5555
   ```
   
   Replace with your phone's IP.

5. **Disconnect USB** (wireless connection is now active)

6. **Verify**:
   ```powershell
   flutter devices
   ```

### 6. Run the App

#### Quick Run:
```powershell
flutter run
```

Flutter will detect your connected device and install the app.

#### Choose Specific Device:
```powershell
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

#### Hot Reload:
While app is running:
- Press `r` to hot reload (fast refresh)
- Press `R` to hot restart (full restart)
- Press `q` to quit

### 7. Build APK (Optional)

To create installable APK:

```powershell
# Build APK
flutter build apk --release

# APK location:
# build\app\outputs\flutter-apk\app-release.apk
```

You can copy this APK to your phone and install it.

## Testing the App

### 1. Ensure Backend is Running

Before testing, make sure Django backend is running:
```powershell
# In Backend directory
python manage.py runserver 192.168.1.8:8000
```

### 2. Test Features

1. **Registration**:
   - Open app
   - Tap "Register"
   - Create new account
   - Should redirect to home screen

2. **Browse Destinations**:
   - View featured treks
   - Scroll through all destinations
   - Search for specific trek

3. **View Details**:
   - Tap on any destination
   - View route map (OpenStreetMap)
   - Check weather information
   - See risk alerts

4. **Group Chat**:
   - Tap "Group Chat" button
   - Send messages
   - Messages should appear in real-time

5. **Book Trek**:
   - Tap "Book Now"
   - Fill in details
   - Submit booking
   - Check "My Bookings" from home

## Troubleshooting

### Cannot Connect to Backend

**Error**: "Failed to connect" or "Network error"

**Solutions**:
1. Verify backend is running: Check terminal
2. Verify IP is correct: `ipconfig`
3. Check firewall: Allow port 8000
4. Test in browser first: http://192.168.1.8:8000/api/destinations/
5. Ensure phone and PC on same WiFi

### Device Not Detected

**Error**: No devices shown in `flutter devices`

**Solutions**:
1. Reconnect USB cable
2. Accept USB debugging on phone
3. Check USB drivers installed
4. Try different USB port
5. Restart adb: `adb kill-server` then `adb start-server`

### Build Errors

**Error**: Build failures or package errors

**Solutions**:
```powershell
# Clean build
flutter clean

# Get packages
flutter pub get

# Rebuild
flutter run
```

### Map Not Loading

**Error**: Map shows blank or tiles not loading

**Solutions**:
1. Check internet connection
2. OpenStreetMap might be slow (wait a moment)
3. Try different zoom level
4. Check Android permissions (location)

### Hot Reload Not Working

**Solutions**:
1. Press `R` for full restart
2. Stop app and run again: `flutter run`
3. Sometimes need to restart IDE

## Project Structure

```
front_end/
├── lib/
│   ├── main.dart              # App entry point
│   │
│   ├── config/
│   │   ├── api_config.dart    # API endpoints
│   │   └── app_theme.dart     # Styling/colors
│   │
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   ├── destination.dart
│   │   ├── trek_route.dart
│   │   ├── weather.dart
│   │   ├── chat.dart
│   │   └── booking.dart
│   │
│   ├── services/              # API services
│   │   ├── auth_service.dart
│   │   ├── destination_service.dart
│   │   ├── chat_service.dart
│   │   └── booking_service.dart
│   │
│   └── screens/               # UI screens
│       ├── splash_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home/
│       │   └── home_screen.dart
│       ├── destinations/
│       │   └── destination_detail_screen.dart
│       ├── chat/
│       │   └── chat_screen.dart
│       └── bookings/
│           ├── booking_form_screen.dart
│           └── bookings_screen.dart
│
├── android/                   # Android config
├── ios/                       # iOS config (if needed)
├── pubspec.yaml              # Dependencies
└── README.md
```

## Useful Commands

```powershell
# Install packages
flutter pub get

# Run app
flutter run

# Run with specific device
flutter run -d <device-id>

# List devices
flutter devices

# Build APK
flutter build apk --release

# Clean project
flutter clean

# Check setup
flutter doctor

# View logs
flutter logs

# Analyze code
flutter analyze

# Format code
flutter format .
```

## Development Tips

### Hot Reload
- Press `r` for quick refresh
- Changes reflect instantly
- Great for UI tweaking

### Debug Mode
While running:
- Press `w` to dump widget tree
- Press `t` to dump rendering tree
- Press `p` to show performance overlay

### VS Code Extensions (Recommended)
1. Flutter
2. Dart
3. Flutter Widget Snippets
4. Awesome Flutter Snippets

### Android Studio Tips
1. Use Android Emulator for testing (no phone needed)
2. Device Manager: Tools → Device Manager
3. Create virtual device with latest Android version

## Network Configuration

### Your Setup
- PC IP: `192.168.1.8`
- Backend: `http://192.168.1.8:8000`
- API: `http://192.168.1.8:8000/api`

### Phone Connection
Phone must be on same WiFi network (192.168.1.x range)

To verify:
1. On phone: Check WiFi IP in Settings
2. Should be like: 192.168.1.xx
3. Ping PC from phone: Use Network Utilities app

## Testing Checklist

- [ ] Backend running at 192.168.1.8:8000
- [ ] Phone connected (USB or WiFi)
- [ ] `flutter devices` shows device
- [ ] API accessible from browser
- [ ] Firewall allows port 8000
- [ ] Phone and PC on same WiFi
- [ ] Flutter app running without errors

## Performance Tips

1. **Use Release Mode for Production**:
   ```powershell
   flutter run --release
   ```
   Much faster, no debug overhead.

2. **Profile Mode for Testing**:
   ```powershell
   flutter run --profile
   ```
   Performance analysis with some debugging.

3. **Reduce Build Size**:
   ```powershell
   flutter build apk --split-per-abi
   ```
   Creates separate APKs for each CPU architecture.

## Next Steps

1. Test all features thoroughly
2. Fix any bugs you find
3. Add your own customizations
4. Prepare for presentation
5. Document any changes

## Support Resources

- Flutter Docs: https://docs.flutter.dev
- Flutter Samples: https://flutter.github.io/samples
- Stack Overflow: Tag [flutter]
- Flutter Community: https://flutter.dev/community

---

**For BCA TU 6th Semester Project**
