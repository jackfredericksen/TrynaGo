import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/app_state.dart';
import '../../widgets/event_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with TickerProviderStateMixin {
  final CardSwiperController controller = CardSwiperController();
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    final currentUser = ref.read(currentUserProvider);
    ref.read(eventsProvider.notifier).loadEvents(
      userLocation: currentUser?.location,
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final eventsState = ref.read(eventsProvider);
    final events = eventsState.events;
    
    if (previousIndex < events.length) {
      final event = events[previousIndex];
      
      if (direction == CardSwiperDirection.right) {
        _handleLike(event);
      } else if (direction == CardSwiperDirection.left) {
        _handlePass(event);
      }
    }
    return true;
  }

  void _handleLike(Event event) {
    ref.read(currentUserProvider.notifier).addLikedEvent(event.id);
    ref.read(eventsProvider.notifier).likeEvent(event.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Interested in "${event.name}"!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePass(Event event) {
    ref.read(currentUserProvider.notifier).addDislikedEvent(event.id);
  }

  void _handleSuperLike(Event event) {
    ref.read(currentUserProvider.notifier).addLikedEvent(event.id);
    ref.read(eventsProvider.notifier).likeEvent(event.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Super liked "${event.name}"! 🌟'),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTapPass() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    controller.swipe(CardSwiperDirection.left);
  }

  void _onTapLike() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
    controller.swipe(CardSwiperDirection.right);
  }

  void _showCreateEventDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEventSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final events = eventsState.events;

    return Scaffold(
      // Remove explicit background color to use theme
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        // Remove explicit backgroundColor to use theme
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateEventDialog();
            },
            tooltip: 'Create Event',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: eventsState.isLoading
          ? _buildLoadingState()
          : events.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Error message if any
                    if (eventsState.error != null)
                      Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, 
                                 color: Theme.of(context).colorScheme.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                eventsState.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ref.read(eventsProvider.notifier).clearError();
                              },
                              child: Icon(Icons.close, 
                                         color: Theme.of(context).colorScheme.primary, size: 16),
                            ),
                          ],
                        ),
                      ),
                    
                    // Location indicator
                    if (currentUser?.location.city != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Activities near ${currentUser!.location.city}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Card swiper
                    Expanded(
                      child: CardSwiper(
                        controller: controller,
                        cardsCount: events.length,
                        onSwipe: _onSwipe,
                        onUndo: (int? previousIndex, int currentIndex,
                            CardSwiperDirection direction) {
                          // Handle undo if needed
                          return true;
                        },
                        numberOfCardsDisplayed: 3,
                        backCardOffset: const Offset(40, 40),
                        padding: const EdgeInsets.all(24.0),
                        cardBuilder: (
                          context,
                          index,
                          horizontalThresholdPercentage,
                          verticalThresholdPercentage,
                        ) {
                          return EventCard(
                            event: events[index],
                            onSuperLike: () => _handleSuperLike(events[index]),
                          );
                        },
                      ),
                    ),
                    
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Pass button
                          AnimatedBuilder(
                            animation: _buttonAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _buttonAnimation.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: _onTapPass,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Undo button (if available)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.undo,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                size: 24,
                              ),
                              onPressed: () {
                                controller.undo();
                              },
                            ),
                          ),
                          
                          // Like button
                          AnimatedBuilder(
                            animation: _buttonAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _buttonAnimation.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.favorite,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                    onPressed: _onTapLike,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Instructions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Swipe right if interested, left to pass, up for super like',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading events...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new activities!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _loadEvents();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class CreateEventSheet extends ConsumerStatefulWidget {
  const CreateEventSheet({super.key});

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Social';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = false;
  bool _isPaid = false;

  final List<String> _categories = [
    'Social',
    'Sports',
    'Outdoor',
    'Networking',
    'Food',
    'Music',
    'Arts',
    'Education',
    'Fitness',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: _selectedTime.format(context),
      location: EventLocation(
        address: _locationController.text.trim(),
        latitude: currentUser.location.latitude + (0.01 * (0.5 - (DateTime.now().millisecond / 1000))),
        longitude: currentUser.location.longitude + (0.01 * (0.5 - (DateTime.now().microsecond / 1000000))),
        city: currentUser.location.city,
        state: currentUser.location.state,
      ),
      category: _selectedCategory,
      attendees: 1,
      maxAttendees: _maxAttendeesController.text.isNotEmpty 
        ? int.tryParse(_maxAttendeesController.text) 
        : null,
      price: _isPaid && _priceController.text.isNotEmpty 
        ? double.tryParse(_priceController.text) 
        : null,
      organizer: currentUser.name,
      source: EventSource.userCreated,
    );

    await ref.read(eventsProvider.notifier).addEvent(newEvent);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event "${newEvent.name}" created successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Create Event',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Event Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'What\'s happening?',
                    prefixIcon: Icon(Icons.event),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell people what to expect...',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please add a description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Where is it happening?',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Date and Time
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, y').format(_selectedDate),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Max Attendees
                TextFormField(
                  controller: _maxAttendeesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Attendees (Optional)',
                    hintText: 'Leave blank for unlimited',
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Paid Event Toggle
                SwitchListTile(
                  title: const Text('Paid Event'),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                    });
                  },
                ),
                
                if (_isPaid) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: _isPaid ? (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    } : null,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Event',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}