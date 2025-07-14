import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/event.dart';

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
}

// Events Provider
final eventsProvider = StateNotifierProvider<EventsNotifier, List<Event>>((ref) {
  return EventsNotifier();
});

class EventsNotifier extends StateNotifier<List<Event>> {
  EventsNotifier() : super(_mockEvents);

  void loadEvents() {
    // TODO: Load events from API
    state = _mockEvents;
  }

  void addEvent(Event event) {
    state = [...state, event];
  }

  void removeEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
  }
}

// Mock Events for Development
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
    ),
    category: 'Outdoor',
    attendees: 12,
    maxAttendees: 20,
    organizer: 'Chicago Hiking Group',
    source: EventSource.meetup,
    tags: ['hiking', 'nature', 'exercise', 'beginners-welcome'],
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
    ),
    category: 'Networking',
    attendees: 15,
    maxAttendees: 25,
    organizer: 'Chicago Developers',
    source: EventSource.meetup,
    tags: ['coding', 'networking', 'coffee', 'developers'],
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
    ),
    category: 'Arts',
    attendees: 45,
    maxAttendees: 60,
    price: 15.0,
    organizer: 'Chicago Art Collective',
    source: EventSource.eventbrite,
    tags: ['art', 'gallery', 'culture', 'wine'],
  ),
];

// Liked Events Provider
final likedEventsProvider = Provider<List<Event>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final allEvents = ref.watch(eventsProvider);
  
  if (currentUser == null) return [];
  
  return allEvents.where((event) => 
    currentUser.likedEvents.contains(event.id)
  ).toList();
});