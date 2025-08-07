import 'package:flutter/material.dart';


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
  final List<String> imageUrls; // Changed from single imageUrl to list
  final String organizer;
  final String? organizerAvatarUrl; // Added organizer avatar
  final EventSource source;
  final List<String> tags;
  final bool isVerified; // Added verification status
  final DateTime? registrationDeadline; // Added registration deadline
  final Map<String, dynamic>? metadata; // For additional data

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
    this.imageUrls = const [],
    required this.organizer,
    this.organizerAvatarUrl,
    required this.source,
    this.tags = const [],
    this.isVerified = false,
    this.registrationDeadline,
    this.metadata,
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
      imageUrls: List<String>.from(json['imageUrls'] ?? json['images'] ?? []),
      organizer: json['organizer'],
      organizerAvatarUrl: json['organizerAvatarUrl'],
      source: EventSource.values.firstWhere(
        (e) => e.toString().split('.').last == json['source'],
        orElse: () => EventSource.userCreated,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      isVerified: json['isVerified'] ?? false,
      registrationDeadline: json['registrationDeadline'] != null 
        ? DateTime.parse(json['registrationDeadline'])
        : null,
      metadata: json['metadata'],
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
      'imageUrls': imageUrls,
      'organizer': organizer,
      'organizerAvatarUrl': organizerAvatarUrl,
      'source': source.toString().split('.').last,
      'tags': tags,
      'isVerified': isVerified,
      'registrationDeadline': registrationDeadline?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper methods
  
  /// Get the primary image URL (first in the list or fallback)
  String? get primaryImageUrl {
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return _getCategoryFallbackImage();
  }

  /// Get fallback image based on category
  String _getCategoryFallbackImage() {
    switch (category.toLowerCase()) {
      case 'outdoor':
        return 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop';
      case 'sports':
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop';
      case 'networking':
        return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=400&h=300&fit=crop';
      case 'food':
        return 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&h=300&fit=crop';
      case 'music':
        return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop';
      case 'arts':
        return 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop';
      case 'education':
        return 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&h=300&fit=crop';
      case 'social':
        return 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&h=300&fit=crop';
      case 'fitness':
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&h=300&fit=crop';
    }
  }

  /// Get all image URLs including fallbacks
  List<String> get allImageUrls {
    if (imageUrls.isNotEmpty) {
      return imageUrls;
    }
    
    // Return category-specific fallback images
    return [
      _getCategoryFallbackImage(),
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=400&h=300&fit=crop',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    ];
  }

  /// Check if event has real uploaded images (not fallbacks)
  bool get hasRealImages => imageUrls.isNotEmpty;

  /// Check if event registration is still open
  bool get isRegistrationOpen {
    if (registrationDeadline == null) return true;
    return DateTime.now().isBefore(registrationDeadline!);
  }

  /// Check if event is full
  bool get isFull {
    if (maxAttendees == null) return false;
    return attendees >= maxAttendees!;
  }

  /// Get days until event
  int get daysUntilEvent {
    return date.difference(DateTime.now()).inDays;
  }

  /// Check if event is happening today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if event is in the past
  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  /// Copy with method for immutable updates
  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? time,
    EventLocation? location,
    String? category,
    int? attendees,
    int? maxAttendees,
    double? price,
    List<String>? imageUrls,
    String? organizer,
    String? organizerAvatarUrl,
    EventSource? source,
    List<String>? tags,
    bool? isVerified,
    DateTime? registrationDeadline,
    Map<String, dynamic>? metadata,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      attendees: attendees ?? this.attendees,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      organizer: organizer ?? this.organizer,
      organizerAvatarUrl: organizerAvatarUrl ?? this.organizerAvatarUrl,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      metadata: metadata ?? this.metadata,
    );
  }
}

class EventLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode; // Added postal code
  final String? venue; // Added venue name

  EventLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.venue,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      venue: json['venue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'venue': venue,
    };
  }

  /// Get formatted address for display
  String get displayAddress {
    if (venue != null) {
      return '$venue, $address';
    }
    return address;
  }

  /// Get short location for display (city, state)
  String get shortLocation {
    if (city != null && state != null) {
      return '$city, $state';
    } else if (city != null) {
      return city!;
    } else if (state != null) {
      return state!;
    }
    return 'Unknown location';
  }
}

enum EventSource {
  meetup,
  eventbrite,
  facebook,
  instagram,
  linkedin,
  userCreated,
  imported,
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
  business,
  technology,
  health,
  gaming,
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
      case EventCategory.business:
        return 'Business';
      case EventCategory.technology:
        return 'Technology';
      case EventCategory.health:
        return 'Health & Wellness';
      case EventCategory.gaming:
        return 'Gaming';
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
      case EventCategory.business:
        return '📊';
      case EventCategory.technology:
        return '💻';
      case EventCategory.health:
        return '🏥';
      case EventCategory.gaming:
        return '🎮';
      case EventCategory.other:
        return '📅';
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.outdoor:
        return const Color(0xFF4CAF50); // Green
      case EventCategory.sports:
        return const Color(0xFFFF9800); // Orange
      case EventCategory.networking:
        return const Color(0xFF2196F3); // Blue
      case EventCategory.food:
        return const Color(0xFFE91E63); // Pink
      case EventCategory.music:
        return const Color(0xFF9C27B0); // Purple
      case EventCategory.arts:
        return const Color(0xFF009688); // Teal
      case EventCategory.education:
        return const Color(0xFF3F51B5); // Indigo
      case EventCategory.social:
        return const Color(0xFF00BCD4); // Cyan
      case EventCategory.fitness:
        return const Color(0xFFF44336); // Red
      case EventCategory.business:
        return const Color(0xFF607D8B); // Blue Grey
      case EventCategory.technology:
        return const Color(0xFF795548); // Brown
      case EventCategory.health:
        return const Color(0xFF8BC34A); // Light Green
      case EventCategory.gaming:
        return const Color(0xFF673AB7); // Deep Purple
      case EventCategory.other:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}