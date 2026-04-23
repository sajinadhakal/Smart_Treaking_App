import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_notification.dart';
import '../../models/destination.dart';
import '../../providers/itinerary_provider.dart';
import '../../providers/mountain_mode_provider.dart';
import '../../services/notification_service.dart';
import 'destination_detail_screen.dart';

class DestinationsListScreen extends StatefulWidget {
  const DestinationsListScreen({super.key});

  @override
  State<DestinationsListScreen> createState() => _DestinationsListScreenState();
}

class _DestinationsListScreenState extends State<DestinationsListScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItineraryProvider>().loadDestinations(ordering: '-average_rating');
      _loadNotifications();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final provider = context.read<ItineraryProvider>();
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      provider.loadMoreDestinations();
    }
  }

  Future<void> _loadDestinations() async {
    await context.read<ItineraryProvider>().loadDestinations(
      search: _currentSearch.isEmpty ? null : _currentSearch,
      ordering: '-average_rating',
    );
  }

  Future<void> _searchDestinations(String query) async {
    _currentSearch = query.trim();
    if (query.isEmpty) {
      await _loadDestinations();
      return;
    }

    await context.read<ItineraryProvider>().loadDestinations(
      search: _currentSearch,
      ordering: '-average_rating',
    );
  }

  Future<void> _loadNotifications() async {
    try {
      final unread = await _notificationService.getUnreadCount();
      final notifications = await _notificationService.getNotifications();
      if (!mounted) {
        return;
      }
      setState(() {
        _unreadCount = unread;
        _notifications = notifications;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _unreadCount = 0;
        _notifications = [];
      });
    }
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

  Future<void> _showNotificationsPanel() async {
    await _loadNotifications();
    if (!mounted) {
      return;
    }

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
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                  await _loadNotifications();
                                } catch (_) {
                                  if (!context.mounted) {
                                    return;
                                  }
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
    final itineraryProvider = context.watch<ItineraryProvider>();
    final destinations = itineraryProvider.destinations;

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Treks'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showNotificationsPanel,
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: _unreadCount > 0 ? Text('$_unreadCount') : null,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchDestinations('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.length > 2 || value.isEmpty) {
                  _searchDestinations(value);
                }
              },
            ),
          ),
          
          // Destinations List
          Expanded(
            child: itineraryProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDestinations,
                    child: itineraryProvider.error != null
                        ? ListView(
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    itineraryProvider.error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : destinations.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('No destinations found')),
                                ],
                              )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: destinations.length + (itineraryProvider.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= destinations.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return _buildDestinationCard(destinations[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    final disableImages = context.watch<MountainModeProvider>().disableImageLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (destination.image != null && !disableImages)
              Image.network(
                destination.image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.terrain, size: 60, color: Colors.grey[600]),
                  );
                },
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (destination.averageRating != null)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              destination.averageRating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today,
                        '${destination.durationDays} days',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.trending_up,
                        destination.difficulty,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.attach_money,
                        'NPR ${destination.price.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
