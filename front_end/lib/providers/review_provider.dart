import 'dart:io';

import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  bool isLoading = false;
  bool isSubmitting = false;
  String? error;

  List<Review> destinationReviews = [];
  List<Review> topReviews = [];

  Future<void> loadReviewsForDestination(int destinationId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      destinationReviews = await _reviewService.getReviews(
        destinationId: destinationId,
        ordering: '-rating,-created_at',
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopReviews() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      topReviews = await _reviewService.getReviews(ordering: '-rating,-created_at');
      if (topReviews.length > 10) {
        topReviews = topReviews.take(10).toList();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReview({
    required int destinationId,
    required int rating,
    required String comment,
    File? imageFile,
  }) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final created = await _reviewService.createReview(
        destinationId: destinationId,
        rating: rating,
        comment: comment,
        imageFile: imageFile,
      );
      destinationReviews = [created, ...destinationReviews];
      topReviews = [created, ...topReviews]..sort((a, b) {
          final byRating = b.rating.compareTo(a.rating);
          if (byRating != 0) return byRating;
          return (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970));
        });
      if (topReviews.length > 10) {
        topReviews = topReviews.take(10).toList();
      }
      return true;
    } catch (e) {
      if (_isAlreadyPostedReviewError(e.toString())) {
        error = null;
        return true;
      }
      error = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
    File? imageFile,
    bool removeImage = false,
  }) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      // Find the review to get its destination ID
      final reviewToUpdate = destinationReviews.firstWhere(
        (r) => r.id == reviewId,
        orElse: () => topReviews.firstWhere(
          (r) => r.id == reviewId,
          orElse: () => throw Exception('Review not found'),
        ),
      );

      final updated = await _reviewService.updateReview(
        reviewId: reviewId,
        destinationId: reviewToUpdate.destination,
        rating: rating,
        comment: comment,
        imageFile: imageFile,
        removeImage: removeImage,
      );

      destinationReviews = destinationReviews.map((r) => r.id == reviewId ? updated : r).toList();
      topReviews = topReviews.map((r) => r.id == reviewId ? updated : r).toList();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(int reviewId) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _reviewService.deleteReview(reviewId);
      destinationReviews.removeWhere((r) => r.id == reviewId);
      topReviews.removeWhere((r) => r.id == reviewId);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool _isAlreadyPostedReviewError(String errorText) {
    final normalized = errorText.toLowerCase();
    return normalized.contains('already posted a review for this destination') ||
        normalized.contains('you have already posted a review for this destination');
  }
}
