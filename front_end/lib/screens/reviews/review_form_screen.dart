import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/destination.dart';
import '../../models/review.dart';
import '../../providers/review_provider.dart';

class ReviewFormScreen extends StatefulWidget {
  final List<Destination> destinations;
  final int? preselectedDestinationId;
  final Review? editingReview;

  const ReviewFormScreen({
    super.key,
    required this.destinations,
    this.preselectedDestinationId,
    this.editingReview,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int? _selectedDestinationId;
  int _rating = 5;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingReview != null) {
      // Pre-fill form with existing review data
      _selectedDestinationId = widget.editingReview!.destination;
      _rating = widget.editingReview!.rating;
      _commentController.text = widget.editingReview!.comment;
      _existingImageUrl = widget.editingReview!.image;
    } else {
      _selectedDestinationId = widget.preselectedDestinationId ??
          (widget.destinations.isNotEmpty
              ? widget.destinations.first.id
              : null);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1200);
    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
      _removeImage = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination.')),
      );
      return;
    }

    final provider = context.read<ReviewProvider>();

    if (widget.editingReview != null) {
      // Update existing review
      final success = await provider.updateReview(
        reviewId: widget.editingReview!.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        imageFile: _selectedImage,
        removeImage: _removeImage,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience updated successfully.')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error?.replaceFirst('Exception: ', '') ??
                  'Failed to update review.')),
        );
      }
    } else {
      // Create new review
      final success = await provider.createReview(
        destinationId: _selectedDestinationId!,
        rating: _rating,
        comment: _commentController.text.trim(),
        imageFile: _selectedImage,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience shared successfully.')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error?.replaceFirst('Exception: ', '') ??
                  'Failed to submit review.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final isEditing = widget.editingReview != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              isEditing ? 'Edit Your Experience' : 'Share Your Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedDestinationId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Destination'),
                items: widget.destinations
                    .map(
                      (d) => DropdownMenuItem<int>(
                        value: d.id,
                        child: Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) => widget.destinations
                    .map(
                      (d) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isEditing
                    ? null
                    : (value) => setState(() => _selectedDestinationId = value),
              ),
              const SizedBox(height: 16),
              const Text('Rating',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                itemSize: 36,
                allowHalfRating: false,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) => _rating = value.toInt(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Experience',
                  hintText: 'Share your trek experience, tips, and highlights.',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.length < 5) {
                    return 'Comment must be at least 5 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (isEditing && _existingImageUrl != null && !_removeImage) ...[
                const Text('Current Image:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(_existingImageUrl!,
                          height: 170, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        onPressed: () => setState(() => _removeImage = true),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!,
                      height: 170, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting ? null : _submit,
                  child: provider.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Update Experience' : 'Post Experience'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
