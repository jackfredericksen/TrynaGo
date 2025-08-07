import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  
  // TODO: Replace with your actual API base URL
  static const String _baseUrl = 'https://api.trynago.com'; // Placeholder
  static const String _apiVersion = 'v1';
  
  /// Initialize the API service
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/$_apiVersion',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  // Auth endpoints
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResponse.success(authResponse);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/auth/register', data: request.toJson());
      
      final authResponse = AuthResponse.fromJson(response.data);
      return ApiResponse.success(authResponse);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // User endpoints
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      final user = User.fromJson(response.data['user']);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<User>> updateUser(User user) async {
    try {
      final response = await _dio.put('/users/me', data: user.toJson());
      final updatedUser = User.fromJson(response.data['user']);
      return ApiResponse.success(updatedUser);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Event endpoints
  Future<ApiResponse<List<Event>>> getEvents({
    double? latitude,
    double? longitude,
    double? radius,
    List<String>? categories,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }
      
      if (radius != null) {
        queryParams['radius'] = radius;
      }
      
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }

      final response = await _dio.get('/events', queryParameters: queryParams);
      
      final events = (response.data['events'] as List)
          .map((json) => Event.fromJson(json))
          .toList();
      
      return ApiResponse.success(events);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Event>> getEvent(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId');
      final event = Event.fromJson(response.data['event']);
      return ApiResponse.success(event);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Event>> createEvent(Event event) async {
    try {
      final response = await _dio.post('/events', data: event.toJson());
      final createdEvent = Event.fromJson(response.data['event']);
      return ApiResponse.success(createdEvent);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<Event>> updateEvent(Event event) async {
    try {
      final response = await _dio.put('/events/${event.id}', data: event.toJson());
      final updatedEvent = Event.fromJson(response.data['event']);
      return ApiResponse.success(updatedEvent);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> deleteEvent(String eventId) async {
    try {
      await _dio.delete('/events/$eventId');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // User event interactions
  Future<ApiResponse<void>> likeEvent(String eventId) async {
    try {
      await _dio.post('/events/$eventId/like');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> unlikeEvent(String eventId) async {
    try {
      await _dio.delete('/events/$eventId/like');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> joinEvent(String eventId) async {
    try {
      await _dio.post('/events/$eventId/join');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> leaveEvent(String eventId) async {
    try {
      await _dio.delete('/events/$eventId/join');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  Future<ApiResponse<List<Event>>> getLikedEvents() async {
    try {
      final response = await _dio.get('/users/me/liked-events');
      final events = (response.data['events'] as List)
          .map((json) => Event.fromJson(json))
          .toList();
      return ApiResponse.success(events);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Image upload
  Future<ApiResponse<String>> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/upload/image', data: formData);
      final imageUrl = response.data['url'] as String;
      return ApiResponse.success(imageUrl);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred');
    }
  }

  // Error handling
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error occurred';
        
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Authentication failed. Please log in again.';
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Resource not found: $message';
          case 422:
            return 'Validation error: $message';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Error: $message';
        }
      
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      
      case DioExceptionType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

// Auth interceptor for adding tokens to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: Get auth token from secure storage
    // final token = await SecureStorage().getAuthToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // TODO: Handle token refresh or logout
      // await AuthService().logout();
    }
    handler.next(err);
  }
}

// Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(success: false, error: error);
  }
}

// Auth models
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final int age;
  final double latitude;
  final double longitude;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}