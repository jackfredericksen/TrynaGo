import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from user
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Get current position with error handling
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Check and request permission
      LocationPermission permission = await checkLocationPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionPermanentlyDeniedException();
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get current location as UserLocation model
  Future<UserLocation?> getCurrentUserLocation() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting user location: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Check if user is within a certain radius of an event
  bool isWithinRadius(
    UserLocation userLocation,
    double eventLatitude,
    double eventLongitude,
    double radiusKm,
  ) {
    double distance = calculateDistance(
      userLocation.latitude,
      userLocation.longitude,
      eventLatitude,
      eventLongitude,
    );
    return distance <= radiusKm;
  }

  /// Get location settings to help user enable location services
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Get app settings to help user change location permissions
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Listen to location changes (for real-time updates)
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update every 100 meters
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Get formatted distance string for UI display
  String getDistanceString(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.round()}km away';
    }
  }

  /// Reverse geocoding (convert coordinates to address) - placeholder
  /// In a real app, you'd use a service like Google Geocoding API
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // This is a placeholder - in a real app you'd use:
      // - Google Geocoding API
      // - Mapbox Geocoding
      // - Or another geocoding service
      
      // For now, return a mock address based on coordinates
      if (latitude > 41.8 && latitude < 42.0 && 
          longitude > -87.7 && longitude < -87.6) {
        return 'Chicago, IL, USA';
      }
      
      return 'Unknown Location';
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Check if we have sufficient location permissions for the app
  Future<bool> hasLocationPermission() async {
    final permission = await checkLocationPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Complete location setup flow with user-friendly error handling
  Future<LocationResult> setupLocation() async {
    try {
      // Step 1: Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        return LocationResult.serviceDisabled();
      }

      // Step 2: Check/request permissions
      final permission = await requestLocationPermission();
      
      if (permission == LocationPermission.denied) {
        return LocationResult.permissionDenied();
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationResult.permissionPermanentlyDenied();
      }

      // Step 3: Get current location
      final position = await getCurrentPosition();
      if (position == null) {
        return LocationResult.locationUnavailable();
      }

      // Step 4: Convert to UserLocation
      final userLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationResult.success(userLocation);
    } catch (e) {
      return LocationResult.error(e.toString());
    }
  }
}

/// Result class for location operations
class LocationResult {
  final bool success;
  final UserLocation? location;
  final String? error;
  final LocationErrorType? errorType;

  LocationResult._({
    required this.success,
    this.location,
    this.error,
    this.errorType,
  });

  factory LocationResult.success(UserLocation location) {
    return LocationResult._(
      success: true,
      location: location,
    );
  }

  factory LocationResult.serviceDisabled() {
    return LocationResult._(
      success: false,
      error: 'Location services are disabled',
      errorType: LocationErrorType.serviceDisabled,
    );
  }

  factory LocationResult.permissionDenied() {
    return LocationResult._(
      success: false,
      error: 'Location permission denied',
      errorType: LocationErrorType.permissionDenied,
    );
  }

  factory LocationResult.permissionPermanentlyDenied() {
    return LocationResult._(
      success: false,
      error: 'Location permission permanently denied',
      errorType: LocationErrorType.permissionPermanentlyDenied,
    );
  }

  factory LocationResult.locationUnavailable() {
    return LocationResult._(
      success: false,
      error: 'Unable to get current location',
      errorType: LocationErrorType.locationUnavailable,
    );
  }

  factory LocationResult.error(String message) {
    return LocationResult._(
      success: false,
      error: message,
      errorType: LocationErrorType.other,
    );
  }
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  locationUnavailable,
  other,
}

/// Custom exceptions
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([this.message = 'Location services are disabled']);
  
  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException([this.message = 'Location permission denied']);
  
  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException([this.message = 'Location permission permanently denied']);
  
  @override
  String toString() => 'LocationPermissionPermanentlyDeniedException: $message';
}