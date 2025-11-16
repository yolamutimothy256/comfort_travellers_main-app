# Bus Tracking Module Implementation Guide

## Overview

This guide outlines what's needed to implement a GPS-based bus tracking module for the Comfort Busses ticketing app. The module will allow real-time tracking of buses on their routes.

## Required Packages

### 1. Location Services
- **`geolocator`** - Primary package for GPS/location services
  - Handles location permissions
  - Provides current location and location updates
  - Works on Android, iOS, and Web

### 2. Maps Display
Choose one of the following:

**Option A: Google Maps (Recommended)**
- **`google_maps_flutter`** - Official Google Maps plugin
  - Requires Google Maps API key
  - Best performance and features
  - Requires billing account (free tier available)

**Option B: OpenStreetMap (Free Alternative)**
- **`flutter_map`** - OpenStreetMap-based solution
  - No API key required
  - Free and open source
  - Good for basic mapping needs

### 3. Background Location (Optional but Recommended)
- **`workmanager`** or **`flutter_background_service`** - For background location updates
  - Keeps tracking active when app is in background
  - Important for continuous bus tracking

## Required Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track bus positions</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track bus positions even when the app is in the background</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track bus positions</string>
```

## Firestore Data Structure

### New Collections

1. **`vehicles/{vehicleId}`**
   ```dart
   {
     vehicleId: string,
     vehicleNumber: string,
     routeId: string?,
     currentTripId: string?,
     isActive: boolean,
     driverId: string?,
     conductorId: string?,
     createdAt: timestamp,
     updatedAt: timestamp
   }
   ```

2. **`vehicleLocations/{vehicleId}`** (Real-time location updates)
   ```dart
   {
     vehicleId: string,
     latitude: number,
     longitude: number,
     heading: number, // Direction in degrees (0-360)
     speed: number, // km/h
     accuracy: number, // meters
     timestamp: timestamp,
     tripId: string?,
     routeId: string?
   }
   ```

3. **`locationHistory/{vehicleId}/history/{timestamp}`** (Optional - for historical tracking)
   ```dart
   {
     latitude: number,
     longitude: number,
     heading: number,
     speed: number,
     timestamp: timestamp
   }
   ```

## Architecture Components

### 1. Location Service
- **Purpose**: Handle GPS location updates
- **Responsibilities**:
  - Request location permissions
  - Get current location
  - Stream location updates
  - Handle location errors
  - Manage background location updates

### 2. Location Repository
- **Purpose**: Manage location data in Firestore
- **Responsibilities**:
  - Update vehicle location in Firestore
  - Subscribe to vehicle location streams
  - Query location history
  - Handle offline location caching

### 3. Tracking Models
- `VehicleModel` - Vehicle information
- `LocationModel` - GPS coordinates and metadata
- `TrackingSessionModel` - Active tracking session

### 4. UI Components
- **Map View**: Display buses on map with markers
- **Live Tracking**: Real-time bus position updates
- **Route Overlay**: Show route path on map
- **Bus List**: List of active buses with status
- **Driver App**: Interface for drivers to start/stop tracking

## Implementation Steps

### Phase 1: Setup & Permissions
1. Add required packages to `pubspec.yaml`
2. Configure Android permissions
3. Configure iOS permissions
4. Request location permissions at runtime
5. Handle permission denial gracefully

### Phase 2: Location Service
1. Create `LocationService` class
2. Implement permission handling
3. Implement location streaming
4. Add error handling
5. Test on physical devices

### Phase 3: Firestore Integration
1. Create location repository
2. Implement location updates to Firestore
3. Create vehicle location streams
4. Add location history (optional)
5. Implement offline support

### Phase 4: Map Display
1. Set up map widget (Google Maps or OpenStreetMap)
2. Display vehicle markers on map
3. Show route overlays
4. Implement real-time marker updates
5. Add info windows/details

### Phase 5: Driver Interface
1. Create driver tracking page
2. Start/stop tracking buttons
3. Show current location
4. Display active trip info
5. Handle trip assignment

### Phase 6: Passenger Interface
1. Create bus tracking page
2. Show selected trip's bus location
3. Display ETA calculations
4. Show route progress
5. Add notifications for bus arrival

### Phase 7: Background Tracking (Advanced)
1. Implement background service
2. Handle app lifecycle
3. Optimize battery usage
4. Add geofencing for route validation
5. Implement location update throttling

## Key Considerations

### 1. Battery Optimization
- Use appropriate location accuracy (not always highest)
- Throttle location updates (e.g., every 30 seconds)
- Use distance-based updates when possible
- Implement smart background tracking

### 2. Data Usage
- Limit location update frequency
- Compress location data
- Use efficient Firestore queries
- Implement local caching

### 3. Privacy & Security
- Only track when trip is active
- Allow drivers to stop tracking
- Secure Firestore rules for location data
- Clear location history after trip completion

### 4. Accuracy
- Use GPS for outdoor tracking
- Fallback to network location if GPS unavailable
- Handle location errors gracefully
- Validate location data before storing

### 5. Cost Management
- Monitor Firestore read/write operations
- Use efficient queries with indexes
- Consider location update frequency vs. cost
- Implement data retention policies

## Google Maps API Setup (If Using Google Maps)

1. **Create API Key**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Maps SDK for Android/iOS
   - Create API key
   - Restrict API key to your app

2. **Android Configuration**
   - Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY"/>
   ```

3. **iOS Configuration**
   - Add to `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY")
   ```

## Testing Checklist

- [ ] Location permissions requested correctly
- [ ] Location updates work in foreground
- [ ] Location updates work in background (if implemented)
- [ ] Map displays correctly
- [ ] Vehicle markers update in real-time
- [ ] Route overlays display correctly
- [ ] Offline location caching works
- [ ] Battery usage is acceptable
- [ ] Data usage is reasonable
- [ ] Error handling works for location failures
- [ ] Works on both Android and iOS

## Estimated Implementation Time

- **Basic Tracking**: 2-3 days
  - Location service, basic map display, Firestore updates
  
- **Full Implementation**: 1-2 weeks
  - All features including background tracking, ETA, route overlays

- **Production Ready**: 2-3 weeks
  - Testing, optimization, error handling, edge cases

## Next Steps

1. Review and approve this implementation plan
2. Choose map provider (Google Maps vs OpenStreetMap)
3. Set up Google Maps API (if using Google Maps)
4. Add required packages
5. Begin Phase 1 implementation

