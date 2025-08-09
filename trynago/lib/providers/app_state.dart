import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

// Service providers
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  service.initialize();
  return service;
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false);

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}

// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  void updateUser(User user) {
    state = user;
  }

  void addLikedEvent(String eventId) {
    if (state != null) {
      final updatedLikedEvents = [...state!.likedEvents, eventId];
      state = state!.copyWith(likedEvents: updatedLikedEvents);
    }
  }

  void addDislikedEvent(String eventId) {
    if (state != null) {
      final updatedDislikedEvents = [...state!.dislikedEvents, eventId];
      state = state!.copyWith(dislikedEvents: updatedDislikedEvents);
    }
  }

  void removeFromLiked(String eventId) {
    if (state != null) {
      final updatedLikedEvents = state!.likedEvents.where((id) => id != eventId).toList();
      state = state!.copyWith(likedEvents: updatedLikedEvents);
    }
  }

  void joinEvent(String eventId) {
    if (state != null) {
      final updatedAttendingEvents = [...state!.attendingEvents, eventId];
      state = state!.copyWith(attendingEvents: updatedAttendingEvents);
    }
  }

  void leaveEvent(String eventId) {
    if (state != null) {
      final updatedAttendingEvents = state!.attendingEvents.where((id) => id != eventId).toList();
      state = state!.copyWith(attendingEvents: updatedAttendingEvents);
    }
  }

  Future<void> updateLocation(UserLocation location) async {
    if (state != null) {
      state = state!.copyWith(location: location);
    }
  }
}

// Location State Provider
final locationStateProvider = StateNotifierProvider<LocationStateNotifier, LocationState>((ref) {
  return LocationStateNotifier(ref.read(locationServiceProvider));
});

class LocationStateNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationStateNotifier(this._locationService) : super(LocationState.initial());

  Future<void> requestLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _locationService.setupLocation();
    
    if (result.success && result.location != null) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: true,
        location: result.location,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        error: result.error,
        errorType: result.errorType,
      );
    }
  }

  Future<void> checkLocationPermission() async {
    final hasPermission = await _locationService.hasLocationPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  void clearError() {
    state = state.copyWith(error: null, errorType: null);
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }
}

class LocationState {
  final bool isLoading;
  final bool hasPermission;
  final UserLocation? location;
  final String? error;
  final LocationErrorType? errorType;

  LocationState({
    required this.isLoading,
    required this.hasPermission,
    this.location,
    this.error,
    this.errorType,
  });

  factory LocationState.initial() {
    return LocationState(
      isLoading: false,
      hasPermission: false,
    );
  }

  LocationState copyWith({
    bool? isLoading,
    bool? hasPermission,
    UserLocation? location,
    String? error,
    LocationErrorType? errorType,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      location: location ?? this.location,
      error: error,
      errorType: errorType,
    );
  }
}

// Events Provider with API integration
final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(
    ref.read(apiServiceProvider),
    ref.read(locationServiceProvider),
  );
});

class EventsNotifier extends StateNotifier<EventsState> {
  final ApiService _apiService;
  final LocationService _locationService;

  EventsNotifier(this._apiService, this._locationService) 
    : super(EventsState.initial()) {
    // Start with mock data, then try to load from API
    _loadMockData();
  }

  void _loadMockData() {
    state = state.copyWith(
      events: _mockEvents,
      isLoading: false,
    );
  }

  Future<void> loadEvents({
    UserLocation? userLocation,
    double radius = 50.0, // 50km radius
    List<String>? categories,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try to load from API first
      final response = await _apiService.getEvents(
        latitude: userLocation?.latitude,
        longitude: userLocation?.longitude,
        radius: radius,
        categories: categories,
      );

      if (response.success && response.data != null) {
        // API call successful
        state = state.copyWith(
          events: response.data!,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        // API call failed, use mock data with error
        state = state.copyWith(
          events: _mockEvents,
          isLoading: false,
          error: response.error ?? 'Failed to load events from server. Using local data.',
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      // Network error or other exception, use mock data
      state = state.copyWith(
        events: _mockEvents,
        isLoading: false,
        error: 'No internet connection. Using sample data.',
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      // Try to create event via API
      final response = await _apiService.createEvent(event);
      
      if (response.success && response.data != null) {
        // API creation successful
        final updatedEvents = [response.data!, ...state.events];
        state = state.copyWith(events: updatedEvents);
      } else {
        // API failed, add locally
        final updatedEvents = [event, ...state.events];
        state = state.copyWith(
          events: updatedEvents,
          error: 'Event created locally. Will sync when connection is restored.',
        );
      }
    } catch (e) {
      // Network error, add locally
      final updatedEvents = [event, ...state.events];
      state = state.copyWith(
        events: updatedEvents,
        error: 'Event created offline. Will sync when connection is restored.',
      );
    }
  }

  void removeEvent(String eventId) {
    final updatedEvents = state.events.where((event) => event.id != eventId).toList();
    state = state.copyWith(events: updatedEvents);
  }

  Future<void> likeEvent(String eventId) async {
    try {
      final response = await _apiService.likeEvent(eventId);
      if (!response.success) {
        // Handle API error but still update locally
        state = state.copyWith(error: 'Failed to sync like with server');
      }
    } catch (e) {
      // Network error, will sync later
      state = state.copyWith(error: 'Like saved locally. Will sync when connection is restored.');
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final response = await _apiService.joinEvent(eventId);
      if (response.success) {
        // Update attendee count locally
        final updatedEvents = state.events.map((event) {
          if (event.id == eventId) {
            return event.copyWith(attendees: event.attendees + 1);
          }
          return event;
        }).toList();
        state = state.copyWith(events: updatedEvents);
      } else {
        state = state.copyWith(error: response.error ?? 'Failed to join event');
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error. Please try again.');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Filter events by category
  List<Event> getEventsByCategory(String category) {
    return state.events.where((event) => 
      event.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Get events within radius of user location
  List<Event> getEventsNearLocation(UserLocation userLocation, double radiusKm) {
    return state.events.where((event) {
      final distance = _locationService.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        event.location.latitude,
        event.location.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }
}

class EventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  EventsState({
    required this.events,
    required this.isLoading,
    this.error,
    this.lastUpdated,
  });

  factory EventsState.initial() {
    return EventsState(
      events: [],
      isLoading: true,
    );
  }

  EventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Liked Events Provider
final likedEventsProvider = Provider<List<Event>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final eventsState = ref.watch(eventsProvider);
  
  if (currentUser == null) return [];
  
  return eventsState.events.where((event) => 
    currentUser.likedEvents.contains(event.id)
  ).toList();
});

// Attending Events Provider
final attendingEventsProvider = Provider<List<Event>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final eventsState = ref.watch(eventsProvider);
  
  if (currentUser == null) return [];
  
  return eventsState.events.where((event) => 
    currentUser.attendingEvents.contains(event.id)
  ).toList();
});

// Nearby Events Provider
final nearbyEventsProvider = Provider<List<Event>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final eventsState = ref.watch(eventsProvider);
  final locationService = ref.read(locationServiceProvider);
  
  if (currentUser?.location == null) return eventsState.events;
  
  return eventsState.events.where((event) {
    final distance = locationService.calculateDistance(
      currentUser!.location.latitude,
      currentUser.location.longitude,
      event.location.latitude,
      event.location.longitude,
    );
    return distance <= 50.0; // 50km radius
  }).toList();
});

// Mock Events for Development (enhanced with better image handling)
final List<Event> _mockEvents = [
  Event(
    id: '1',
    name: 'Saturday Morning Hike',
    description: 'Join us for a refreshing hike through the local trails. All skill levels welcome! We\'ll explore beautiful nature paths and enjoy great company.',
    date: DateTime.now().add(const Duration(days: 2)),
    time: '8:00 AM',
    location: EventLocation(
      address: 'Lincoln Park, Chicago, IL',
      latitude: 41.9189,
      longitude: -87.6359,
      city: 'Chicago',
      state: 'IL',
      venue: 'Lincoln Park Trailhead',
    ),
    category: 'Outdoor',
    attendees: 12,
    maxAttendees: 20,
    organizer: 'Chicago Hiking Group',
    source: EventSource.meetup,
    tags: ['hiking', 'nature', 'exercise', 'beginners-welcome'],
    isVerified: true,
    imageUrls: [
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=400&h=300&fit=crop',
    ],
  ),
  Event(
    id: '2',
    name: 'Pickup Basketball Game',
    description: 'Casual basketball game at the local court. Bring your A-game and meet fellow basketball enthusiasts!',
    date: DateTime.now().add(const Duration(days: 1)),
    time: '6:00 PM',
    location: EventLocation(
      address: 'Millennium Park Basketball Court, Chicago, IL',
      latitude: 41.8826,
      longitude: -87.6226,
      city: 'Chicago',
      state: 'IL',
      venue: 'Millennium Park Courts',
    ),
    category: 'Sports',
    attendees: 8,
    maxAttendees: 12,
    organizer: 'Chicago Ballers',
    source: EventSource.userCreated,
    tags: ['basketball', 'sports', 'casual', 'evening'],
  ),
  Event(
    id: '3',
    name: 'Coffee & Code',
    description: 'Bring your laptop and join fellow developers for coffee and coding. Great networking opportunity!',
    date: DateTime.now().add(const Duration(days: 3)),
    time: '10:00 AM',
    location: EventLocation(
      address: 'Starbucks Reserve, River North, Chicago, IL',
      latitude: 41.8955,
      longitude: -87.6295,
      city: 'Chicago',
      state: 'IL',
      venue: 'Starbucks Reserve Roastery',
    ),
    category: 'Networking',
    attendees: 15,
    maxAttendees: 25,
    organizer: 'Chicago Developers',
    source: EventSource.meetup,
    tags: ['coding', 'networking', 'coffee', 'developers'],
    isVerified: true,
  ),
  Event(
    id: '4',
    name: 'Yoga in the Park',
    description: 'Outdoor yoga session suitable for all levels. Bring your own mat and water bottle.',
    date: DateTime.now().add(const Duration(days: 4)),
    time: '7:00 AM',
    location: EventLocation(
      address: 'Grant Park, Chicago, IL',
      latitude: 41.8755,
      longitude: -87.6244,
      city: 'Chicago',
      state: 'IL',
      venue: 'Grant Park Pavilion',
    ),
    category: 'Fitness',
    attendees: 20,
    maxAttendees: 30,
    organizer: 'Chicago Yoga Community',
    source: EventSource.eventbrite,
    tags: ['yoga', 'fitness', 'outdoor', 'meditation'],
  ),
  Event(
    id: '5',
    name: 'Local Art Gallery Opening',
    description: 'Explore new contemporary art pieces by local Chicago artists. Wine and light refreshments provided.',
    date: DateTime.now().add(const Duration(days: 5)),
    time: '7:00 PM',
    location: EventLocation(
      address: 'River North Gallery District, Chicago, IL',
      latitude: 41.8919,
      longitude: -87.6278,
      city: 'Chicago',
      state: 'IL',
      venue: 'Contemporary Art Space',
    ),
    category: 'Arts',
    attendees: 45,
    maxAttendees: 60,
    price: 15.0,
    organizer: 'Chicago Art Collective',
    source: EventSource.eventbrite,
    tags: ['art', 'gallery', 'culture', 'wine'],
    isVerified: true,
    registrationDeadline: DateTime.now().add(const Duration(days: 4)),
  ),
];