class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String? bio;
  final List<String> interests;
  final UserLocation location;
  final String? profilePictureUrl;
  final List<String> likedEvents;
  final List<String> dislikedEvents;
  final List<String> attendingEvents;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.bio,
    this.interests = const [],
    required this.location,
    this.profilePictureUrl,
    this.likedEvents = const [],
    this.dislikedEvents = const [],
    this.attendingEvents = const [],
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      age: json['age'],
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      location: UserLocation.fromJson(json['location']),
      profilePictureUrl: json['profilePictureUrl'],
      likedEvents: List<String>.from(json['likedEvents'] ?? []),
      dislikedEvents: List<String>.from(json['dislikedEvents'] ?? []),
      attendingEvents: List<String>.from(json['attendingEvents'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'bio': bio,
      'interests': interests,
      'location': location.toJson(),
      'profilePictureUrl': profilePictureUrl,
      'likedEvents': likedEvents,
      'dislikedEvents': dislikedEvents,
      'attendingEvents': attendingEvents,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? bio,
    List<String>? interests,
    UserLocation? location,
    String? profilePictureUrl,
    List<String>? likedEvents,
    List<String>? dislikedEvents,
    List<String>? attendingEvents,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      likedEvents: likedEvents ?? this.likedEvents,
      dislikedEvents: dislikedEvents ?? this.dislikedEvents,
      attendingEvents: attendingEvents ?? this.attendingEvents,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
    };
  }
}