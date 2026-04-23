# Frontend Mock Mode Setup

## What Changed

The frontend has been configured to run **independently without the backend** using mock data. This allows you to test and develop the UI without needing the Django backend to be running.

## How It Works

### Mock Data Location
All mock data is stored in `lib/mock_data/`:
- `mock_destinations.dart` - Sample trek destinations
- `mock_bookings.dart` - Sample user bookings
- `mock_weather.dart` - Simulated weather data
- `mock_trek_routes.dart` - Trek route details
- `mock_chat.dart` - Chat messages and rooms
- `mock_users.dart` - User authentication data

### Services Updated
All service files have been modified to support mock mode:
- `auth_service.dart` - Authentication (login/register/logout)
- `booking_service.dart` - Booking management
- `destination_service.dart` - Destination and trek data
- `chat_service.dart` - Chat functionality

Each service has a `useMockData` flag set to `true`.

## How to Use Mock Mode

### Login Credentials
Since we're using mock data, **any username and password will work** for login. For example:
- Username: `demo`
- Password: `password`

The app will create a mock user session and you can start exploring!

### Available Features in Mock Mode
✅ Login/Register (accepts any credentials)
✅ Browse destinations (6 sample destinations)
✅ View destination details
✅ Check weather information
✅ View trek routes
✅ See bookings (3 sample bookings)
✅ Chat functionality (with sample messages)

### Switching Between Mock and Real Backend

To **enable mock mode** (current setting):
```dart
// In each service file (auth_service.dart, booking_service.dart, etc.)
static const bool useMockData = true;
```

To **disable mock mode** and use real backend:
```dart
// Change to false in all service files
static const bool useMockData = false;
```

Or update the central flag in `api_config.dart`:
```dart
static const bool useMockData = false;
```

## Running the Frontend

1. Make sure you have Flutter installed
2. Navigate to the frontend directory:
   ```bash
   cd front_end
   ```

3. Get dependencies (if not already done):
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```
   Or select a device in VS Code and press F5

5. Login with any credentials (e.g., username: `demo`, password: `test`)

6. Explore the app! All data is simulated and stored locally.

## What to Test

### Navigation & UI
- [ ] Splash screen displays
- [ ] Login screen works
- [ ] Register screen works
- [ ] Home screen loads with destinations
- [ ] Bottom navigation bar works
- [ ] Can navigate between screens

### Destinations
- [ ] Destination list displays correctly
- [ ] Can search destinations
- [ ] Destination details page shows
- [ ] Weather information displays
- [ ] Trek route shows day-by-day itinerary
- [ ] Can view destination on map

### Bookings
- [ ] Bookings screen shows sample bookings
- [ ] Different booking statuses display (Pending, Confirmed, Completed)
- [ ] Can create new booking
- [ ] Booking details are visible

### Chat
- [ ] Chat screen loads
- [ ] Can view sample messages
- [ ] Can send messages (they appear instantly)
- [ ] Messages display with timestamps

### Profile
- [ ] Profile screen shows user info
- [ ] Can logout successfully

## Benefits of Mock Mode

1. **No Backend Required** - Test frontend without Django running
2. **Faster Development** - No network delays, instant responses
3. **Offline Testing** - Work without internet connection
4. **UI Focus** - Perfect for UI/UX development and testing
5. **Demo Ready** - Show the app to others without setup

## Next Steps

Once you verify the frontend works correctly with mock data, you can:
1. Switch `useMockData` to `false` in service files
2. Start the Django backend
3. Connect frontend to real API
4. Test with real data and database

## Notes

- Mock data persists only during the app session
- Creating new bookings will appear to work but won't be saved permanently
- Authentication tokens are mock tokens (e.g., `mock_token_1`)
- All data resets when you restart the app
- Network delays are simulated with `Future.delayed()` for realistic feel

## Questions?

If you encounter any issues:
1. Check that `useMockData = true` in all service files
2. Make sure Flutter dependencies are installed (`flutter pub get`)
3. Restart the app if needed
4. Check console for any error messages
