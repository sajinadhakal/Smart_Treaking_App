import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../providers/review_provider.dart';
import 'review_form_screen.dart';

class DestinationReviewsScreen extends StatefulWidget {
  final Destination destination;
  final List<Destination> allDestinations;

  const DestinationReviewsScreen({
    super.key,
    required this.destination,
    required this.allDestinations,
  });

  @override
  State<DestinationReviewsScreen> createState() => _DestinationReviewsScreenState();
}

class _DestinationReviewsScreenState extends State<DestinationReviewsScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviewsForDestination(widget.destination.id);
    });
  }

  Future<void> _editReview(Review review) async {
    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(
          destinations: widget.allDestinations,
          editingReview: review,
        ),
      ),
    );

    if (edited == true && mounted) {
      await context.read<ReviewProvider>().loadReviewsForDestination(widget.destination.id);
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
        await context.read<ReviewProvider>().loadReviewsForDestination(widget.destination.id);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.destination.name} Reviews')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ReviewFormScreen(
                destinations: widget.allDestinations,
                preselectedDestinationId: widget.destination.id,
              ),
            ),
          );

          if (created == true && mounted) {
            await context.read<ReviewProvider>().loadReviewsForDestination(widget.destination.id);
          }
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('Share Experience'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ReviewProvider>().loadReviewsForDestination(widget.destination.id),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            provider.error!.replaceFirst('Exception: ', ''),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  )
                : provider.destinationReviews.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No reviews yet. Be the first to share.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.destinationReviews.length,
                        itemBuilder: (context, index) {
                          final review = provider.destinationReviews[index];
                          return FutureBuilder(
                            future: _authService.getUser(),
                            builder: (context, snapshot) {
                              final currentUser = snapshot.data;
                              final isOwnReview = currentUser?.id == review.userId;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
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
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          RatingBarIndicator(
                                            rating: review.rating.toDouble(),
                                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                            itemCount: 5,
                                            itemSize: 18,
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
                                      const SizedBox(height: 8),
                                      Text(review.comment),
                                      if (review.image != null && review.image!.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            review.image!,
                                            fit: BoxFit.cover,
                                            height: 180,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }
}
