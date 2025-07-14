import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final events = ref.read(eventsProvider);
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

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
      body: events.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Activities near ${currentUser!.location.city}',
                          style: TextStyle(
                            color: Colors.grey[600],
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
                      return EventCard(event: events[index]);
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.undo,
                            color: Colors.grey[600],
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
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
                    'Swipe right if interested, left to pass',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new activities!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(eventsProvider.notifier).loadEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}