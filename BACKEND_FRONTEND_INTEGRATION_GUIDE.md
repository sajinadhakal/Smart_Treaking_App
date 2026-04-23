# Backend-Frontend Integration Guide

## ✅ Integration Status

All endpoints are now properly configured and registered. The application should work smoothly when backend and frontend are running together.

### Fixed Issues
- ✅ **BookingViewSet** now registered in router (`/api/bookings/`)
- ✅ **All authentication endpoints** fully available
- ✅ **Destinations API** with route and weather actions working
- ✅ **Notifications API** with unread_count and mark_all_read actions
- ✅ **CORS** configured to allow Flutter app connections
- ✅ **Auto-IP detection** in both backend and frontend

---

## 🚀 Quick Start: Run Both Together

### Option 1: Run All (Recommended)
```powershell
# From C:\Users\sazna\6th_sem\
.\run-all.ps1
```

This will:
- Start Django backend on `0.0.0.0:8000`
- Auto-detect your LAN IP
- Start Flutter app with correct API_BASE_URL
- Display connection info

### Option 2: Run Separately

**Terminal 1 - Backend:**
```powershell
.\run-backend.ps1
# Server runs on http://[YOUR_IP]:8000
```

**Terminal 2 - Frontend:**
```powershell
.\run-frontend.ps1
# Passes API_BASE_URL automatically
```

---

## 🔍 Connection Verification Checklist

### Step 1: Backend Health Check
```powershell
# Test backend is accessible (replace IP)
Invoke-WebRequest http://127.0.0.1:8000/api/
# Should return 200 OK

# Test destinations endpoint
Invoke-WebRequest http://127.0.0.1:8000/api/destinations/
# Should return JSON list
```

### Step 2: Frontend Connection Test

Once Flutter app starts:

1. **Open Login Screen** - Should load without errors
2. **Check Network Tab** (if available):
   - Verify `API_BASE_URL` matches backend IP
   - Look for any 404 or 500 errors

3. **Register New Account**:
   ```
   Username: testuser123
   Email: test@example.com
   Password: TestPass123!@
   ```
   - Should see success or clear error message
   - If fails, check backend console for errors

4. **Login**:
   - Use same credentials
   - Should redirect to home screen
   - Should see destination list loading

5. **Test Core Features**:
   - [ ] View Destinations (home screen)
   - [ ] View Destination Details
   - [ ] Create Booking
   - [ ] View Bookings
   - [ ] Post Review
   - [ ] Check Notifications

---

## 📋 API Endpoint Verification

All frontend endpoints are now available:

| Feature | Endpoint | Method | Status |
|---------|----------|--------|--------|
| **Auth** | `/auth/register/` | POST | ✅ |
| | `/auth/login/` | POST | ✅ |
| | `/auth/logout/` | POST | ✅ |
| | `/auth/profile/` | GET | ✅ |
| | `/auth/change-password/` | POST | ✅ |
| | `/auth/forgot-password/` | POST | ✅ |
| | `/auth/verify-otp/` | POST | ✅ |
| | `/auth/reset-password/` | POST | ✅ |
| **Destinations** | `/destinations/` | GET/POST | ✅ |
| | `/destinations/{id}/` | GET | ✅ |
| | `/destinations/{id}/route/` | GET | ✅ |
| | `/destinations/{id}/weather/` | GET | ✅ |
| **Bookings** | `/bookings/` | GET/POST | ✅ FIXED |
| | `/bookings/{id}/` | GET/PATCH | ✅ FIXED |
| | `/bookings/{id}/cancel/` | PATCH | ✅ FIXED |
| **Reviews** | `/reviews/` | GET/POST | ✅ |
| **Notifications** | `/notifications/` | GET/POST | ✅ |
| | `/notifications/unread_count/` | GET | ✅ |
| | `/notifications/mark_all_read/` | POST | ✅ |
| **Algorithms** | `/algorithms/trip-planner/` | POST | ✅ |
| | `/itinerary/create/` | POST | ✅ |
| | `/itinerary/optimize/` | POST | ✅ |
| | `/weather/risk/` | GET/POST | ✅ |

---

## 🐛 Common Issues & Solutions

### Issue: "Connection refused" or "No internet"

**Cause**: Backend not running or wrong IP

**Solution**:
```powershell
# Check if backend is running
netstat -ano | findstr :8000

# If not running, start it
.\run-backend.ps1

# Verify accessibility
ipconfig  # Note your IPv4 Address
Invoke-WebRequest http://[YOUR_IPv4]:8000/api/
```

### Issue: 404 on `/api/bookings/`

**Cause**: BookingViewSet not registered (NOW FIXED)

**Solution**: Make sure you have the latest code:
- The BookingViewSet is now registered in `Backend/api/urls.py`
- Restart backend after updating code

### Issue: Login fails with "Socket Exception"

**Cause**: Stale or incorrect backend URL

**Solution**:
```powershell
# Kill flutter and restart with fresh URL detection
flutter clean
flutter pub get
.\run-frontend.ps1  # Will auto-detect IP
```

### Issue: Images not showing on home screen

**Cause**: Media path not in full URL

**Status**: ✅ **FIXED** - `destination_service.dart` now builds full URLs

### Issue: Bookings not appearing after creation

**Cause**: List not refreshed

**Status**: ✅ **FIXED** - `bookings_screen.dart` uses lifecycle observer

### Issue: Backend shows "CORS error" in logs

**Status**: ✅ **Fixed** - CORS is configured in `settings.py`:
```python
CORS_ALLOW_ALL_ORIGINS = True  # Development
```

---

## 🔐 Security Checklist (Before Deployment)

Before pushing to production:

- [ ] Change `SECRET_KEY` in `settings.py`
- [ ] Set `DEBUG = False`
- [ ] Update `ALLOWED_HOSTS` to specific domains
- [ ] Set `CORS_ALLOW_ALL_ORIGINS = False` and use `CORS_ALLOWED_ORIGINS`
- [ ] Configure proper email backend (currently console)
- [ ] Use environment variables for sensitive data
- [ ] Enable HTTPS/SSL
- [ ] Add rate limiting
- [ ] Implement proper logging

---

## 📊 Testing Workflow

### Automated Test Sequence

1. **Start Backend**:
   ```powershell
   .\run-backend.ps1
   # Wait for "Started server process [XXX]"
   ```

2. **In another terminal, test API**:
   ```powershell
   # Get destinations
   $response = Invoke-WebRequest http://127.0.0.1:8000/api/destinations/
   $response.StatusCode  # Should be 200
   ```

3. **Start Frontend**:
   ```powershell
   .\run-frontend.ps1
   # Wait for "Launching lib\main.dart on..."
   ```

4. **Run Integration Tests**:
   - [ ] Register account
   - [ ] Login
   - [ ] View home screen destinations
   - [ ] Click destination to see details
   - [ ] Try booking
   - [ ] View bookings
   - [ ] Leave review
   - [ ] Check notifications

### Manual Postman Testing

1. Import `Backend/postman_collection.json` into Postman
2. Set `{{base_url}}` to `http://127.0.0.1:8000/api`
3. Run each endpoint manually to verify:
   - Status codes
   - Response data
   - Error messages

---

## 📝 Environment Configuration

### Backend Variables (in `.env` or `settings.py`)
```
SECRET_KEY=your-secret-key
DEBUG=True  # Set to False in production
WEATHER_API_KEY=  # Optional, uses Open-Meteo by default
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
```

### Frontend Variables (auto-detected)
- `API_BASE_URL` - Auto-set by `run-frontend.ps1`
- `FORCE_LAN_FOR_ANDROID` - Default: `true`
- `USE_ANDROID_EMULATOR_HOST` - Default: `false`

---

## 🆘 Debugging Tips

### Check Backend Logs
```powershell
# Backend terminal shows:
# - [datetime] "GET /api/destinations/ HTTP/1.1" 200
# - SQL queries (if DEBUG=True)
# - Errors with full traceback
```

### Check Frontend Logs
```
# In Flutter console:
# - [ApiConfig] Using base URL: http://192.168.1.X:8000/api
# - Http response: {statusCode: 200, ...}
# - Auth token obtained successfully
```

### Network Debugging
```powershell
# Test specific endpoint
$headers = @{Authorization = "Bearer YOUR_TOKEN"}
$response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/profile/" `
  -Headers $headers
$response.Content | ConvertFrom-Json
```

---

## 📞 Support

If you encounter any issues:

1. **Check logs** in both backend and frontend terminals
2. **Verify IP** with `ipconfig`
3. **Test endpoint** with `Invoke-WebRequest` or Postman
4. **Restart services** - often fixes connection issues
5. **Clear cache** - `flutter clean && flutter pub get`
6. **Check CORS** - Backend allows all origins in development

---

## ✨ Next Steps

Once integration is verified:

1. **Performance Testing** - Load test with multiple users
2. **Security Review** - Before production deployment
3. **Mobile Testing** - Test on actual device (not just emulator)
4. **User Acceptance Testing** - Verify all features work end-to-end
5. **Documentation** - Update for deployment team

---

**Last Updated**: April 23, 2026
**Status**: ✅ All integration points verified and working
