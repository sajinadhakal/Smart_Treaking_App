import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/destination_service.dart';
import '../../services/notification_service.dart';
import '../../models/destination.dart';
import '../../models/review.dart';
import '../../models/user.dart';
import '../../models/app_notification.dart';
import '../../providers/mountain_mode_provider.dart';
import '../../providers/review_provider.dart';
import '../destinations/destination_detail_screen.dart';
import '../reviews/destination_reviews_screen.dart';
import '../reviews/review_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  
  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DestinationService _destinationService = DestinationService();
  final NotificationService _notificationService = NotificationService();
  
  User? _currentUser;
  List<Destination> _featuredDestinations = [];
  List<Destination> _masterDestinations = [];
  List<Destination> _visibleDestinations = [];
  List<Destination> _allDestinations = [];
  List<Destination> _recentDestinations = [];
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _showRecentSection = false;
  Timer? _recentSectionTimer;
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  String? _selectedDifficulty;
  double? _minRating;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadTopReviews();
    });
  }

  @override
  void dispose() {
    _recentSectionTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _currentUser = await _authService.getUser();
    _featuredDestinations = await _destinationService.getFeaturedDestinations();
    _masterDestinations = await _destinationService.getDestinations();
    _recentDestinations = await _destinationService.getDestinations(ordering: '-created_at');
    _recentDestinations = _recentDestinations.take(5).toList();
    _applyFilters();
    _startRecentSectionTimer();
    if (mounted) {
      await context.read<ReviewProvider>().loadTopReviews();
    }

    try {
      _unreadCount = await _notificationService.getUnreadCount();
      _notifications = await _notificationService.getNotifications();
    } catch (_) {
      _unreadCount = 0;
      _notifications = [];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _searchDestinations(String query) async {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    List<Destination> filtered = [..._masterDestinations];

    if (query.isNotEmpty) {
      filtered = filtered.where((d) {
        final searchable = '${d.name} ${d.location} ${d.description}'.toLowerCase();
        return searchable.contains(query);
      }).toList();
    }

    if (_selectedDifficulty != null) {
      final selected = _selectedDifficulty!.toUpperCase();
      filtered = filtered.where((d) {
        final level = d.difficultyLevel.toUpperCase();
        if (selected == 'EASY') {
          return level == 'EASY';
        }
        if (selected == 'MODERATE') {
          return level == 'MODERATE';
        }
        if (selected == 'HARD') {
          return level == 'CHALLENGING' || level == 'DIFFICULT';
        }
        return d.difficulty.toUpperCase() == selected || level == selected;
      }).toList();
    }

    if (_minRating != null && _minRating! > 0) {
      filtered = filtered.where((d) => (d.averageRating ?? 0) >= _minRating!).toList();
    }

    setState(() {
      _visibleDestinations = filtered;
      _allDestinations = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedDifficulty = null;
      _minRating = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _startRecentSectionTimer() {
    _recentSectionTimer?.cancel();
    _showRecentSection = true;
    _recentSectionTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showRecentSection = false;
        });
      }
    });
  }

  Future<void> _showNotificationsPanel() async {
    try {
      _notifications = await _notificationService.getNotifications();
      _unreadCount = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierLabel: 'Notifications',
      barrierDismissible: true,
      barrierColor: Colors.black26,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12, left: 40),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360, maxHeight: 430),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Notifications',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (_notifications.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                try {
                                  await _notificationService.markAllRead();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                  await _loadData();
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to mark notifications as read.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.done_all, size: 18),
                              label: const Text('Mark all read'),
                            ),
                          ),
                        ),
                      Expanded(
                        child: _notifications.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('No notifications yet'),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = _notifications[index];
                                  return ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${index + 1}.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          item.isRead
                                              ? Icons.notifications_none
                                              : Icons.notifications_active,
                                          color: item.isRead
                                              ? Colors.grey
                                              : Theme.of(context).colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                    title: Text(item.title),
                                    subtitle: Text(item.message),
                                    trailing: Text(
                                      _formatNotificationTime(item.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.12, -0.08), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final activeFiltersCount = [
      if (_selectedDifficulty != null) 1,
      if (_minRating != null) 1,
      if (_searchController.text.trim().isNotEmpty) 1,
    ].length;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text('Nepal Trekking'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: _unreadCount > 0 ? Text('$_unreadCount') : null,
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: _showNotificationsPanel,
          ),
        ],
      ) : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'User Trek Experience',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search Bar and Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search destinations...',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              _applyFilters();
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: _searchDestinations,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Badge(
                                  label: activeFiltersCount > 0
                                      ? Text('$activeFiltersCount')
                                      : null,
                                  child: const Icon(Icons.filter_list),
                                ),
                                onPressed: () {
                                  setState(() => _showFilters = !_showFilters);
                                },
                              ),
                            ],
                          ),
                          if (_showFilters)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Difficulty Level',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: const ['Easy', 'Medium', 'Hard']
                                        .map((diff) {
                                      final mappedValue = diff
                                          .toUpperCase()
                                          .replaceAll('MEDIUM', 'MODERATE');
                                      return FilterChip(
                                        label: Text(diff),
                                        selected:
                                            _selectedDifficulty == mappedValue,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedDifficulty =
                                                selected ? mappedValue : null;
                                          });
                                          _applyFilters();
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Minimum Rating',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [3.0, 3.5, 4.0, 4.5].map((rating) {
                                      return FilterChip(
                                        label: Text('$rating★'),
                                        selected: _minRating == rating,
                                        onSelected: (selected) {
                                          setState(() {
                                            _minRating = selected ? rating : null;
                                          });
                                          _applyFilters();
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _resetFilters,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reset Filters'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Featured Destinations
                    if (_featuredDestinations.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Featured Treks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _featuredDestinations.length,
                          itemBuilder: (context, index) {
                            return _buildFeaturedCard(_featuredDestinations[index]);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    if (reviewProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (reviewProvider.topReviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text('No shared experiences yet.'),
                      )
                    else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reviewProvider.topReviews.length,
                      itemBuilder: (context, index) {
                        final review = reviewProvider.topReviews[index];
                        return _buildPostCard(review);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPostCard(Review review) {
    final disableImages = context.watch<MountainModeProvider>().disableImageLoading;
    final hasImage = review.image != null && review.image!.isNotEmpty && !disableImages;
    final isOwnReview = _currentUser?.id == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final destination = _findDestinationById(review.destination);
          if (destination == null) {
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DestinationReviewsScreen(
                destination: destination,
                allDestinations: _allDestinations,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  if (isOwnReview)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                          onTap: () => _editReview(review),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: const [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () => _deleteReview(review),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                review.destinationName,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (starIndex) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      starIndex < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    review.image!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.image, color: Colors.grey[500]),
                ),
              const SizedBox(height: 8),
              Text(
                review.comment,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editReview(Review review) async {
    final destination = _findDestinationById(review.destination);
    if (destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination not found'), backgroundColor: Colors.red),
      );
      return;
    }

    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(
          destinations: _allDestinations,
          editingReview: review,
        ),
      ),
    );

    if (edited == true && mounted) {
      await context.read<ReviewProvider>().loadTopReviews();
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<ReviewProvider>().deleteReview(review.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully'), backgroundColor: Colors.green),
        );
        await context.read<ReviewProvider>().loadTopReviews();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFeaturedCard(Destination destination) {
    final disableImages = context.watch<MountainModeProvider>().disableImageLoading;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(destination: destination),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
                destination.image != null && !disableImages
                  ? Image.network(
                      destination.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NPR ${_resolveNprPrice(destination).toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime? createdAt) {
    if (createdAt == null) {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h';
    }
    return '${diff.inDays}d';
  }

  Widget _buildDestinationCard(Destination destination) {
    final disableImages = context.watch<MountainModeProvider>().disableImageLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: destination.image != null && !disableImages
                    ? Image.network(
                        destination.image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today,
                          '${destination.durationDays}D',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.terrain,
                          '${destination.altitude}m',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(destination.difficulty)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            destination.difficulty,
                            style: TextStyle(
                              color: _getDifficultyColor(destination.difficulty),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'NPR ${_resolveNprPrice(destination).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: Icon(Icons.terrain, size: 40, color: Colors.grey[500]),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MODERATE':
        return Colors.orange;
      case 'CHALLENGING':
        return Colors.deepOrange;
      case 'DIFFICULT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Destination? _findDestinationById(int destinationId) {
    for (final destination in _masterDestinations) {
      if (destination.id == destinationId) {
        return destination;
      }
    }
    return null;
  }

  double _resolveNprPrice(Destination destination) {
    if (destination.basePriceNpr > 0) {
      return destination.basePriceNpr;
    }
    if (destination.price > 0) {
      return destination.price * 132;
    }
    return 0;
  }
}
