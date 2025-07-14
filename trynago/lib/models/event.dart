class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String time;
  final EventLocation location;
  final String category;
  final int attendees;
  final int? maxAttendees;
  final double? price;
  final String? imageUrl;
  final String organizer;
  final EventSource source;
  final List<String> tags;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.attendees,
    this.maxAttendees,
    this.price,
    this.imageUrl,
    required this.organizer,
    required this.source,
    this.tags = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: EventLocation.fromJson(json['location']),
      category: json['category'],
      attendees: json['attendees'],
      maxAttendees: json['maxAttendees'],
      price: json['price']?.toDouble(),
      imageUrl: json['imageUrl'],
      organizer: json['organizer'],
      source: EventSource.values.firstWhere(
        (e) => e.toString().split('.').last == json['source'],
        orElse: () => EventSource.userCreated,
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location.toJson(),
      'category': category,
      'attendees': attendees,
      'maxAttendees': maxAttendees,
      'price': price,
      'imageUrl': imageUrl,
      'organizer': organizer,
      'source': source.toString().split('.').last,
      'tags': tags,
    };
  }
}

class EventLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;

  EventLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      city: json['city'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
    };
  }
}

enum EventSource {
  meetup,
  eventbrite,
  facebook,
  userCreated,
}

enum EventCategory {
  outdoor,
  sports,
  networking,
  food,
  music,
  arts,
  education,
  social,
  fitness,
  other,
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.outdoor:
        return 'Outdoor';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.networking:
        return 'Networking';
      case EventCategory.food:
        return 'Food & Drink';
      case EventCategory.music:
        return 'Music';
      case EventCategory.arts:
        return 'Arts & Culture';
      case EventCategory.education:
        return 'Education';
      case EventCategory.social:
        return 'Social';
      case EventCategory.fitness:
        return 'Fitness';
      case EventCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case EventCategory.outdoor:
        return '🌲';
      case EventCategory.sports:
        return '⚽';
      case EventCategory.networking:
        return '💼';
      case EventCategory.food:
        return '🍕';
      case EventCategory.music:
        return '🎵';
      case EventCategory.arts:
        return '🎨';
      case EventCategory.education:
        return '📚';
      case EventCategory.social:
        return '👥';
      case EventCategory.fitness:
        return '💪';
      case EventCategory.other:
        return '📅';
    }
  }
}