import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingFormScreen extends StatefulWidget {
  final Destination destination;

  const BookingFormScreen({super.key, required this.destination});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  
  DateTime? _startDate;
  int _numberOfPeople = 1;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      if (!picked.isAfter(DateTime.now())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookings must start from tomorrow.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _startDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final booking = Booking(
      destination: widget.destination.id,
      startDate: _startDate!,
      numberOfPeople: _numberOfPeople,
      contactPhone: _phoneController.text.trim(),
      specialRequirements: _requirementsController.text.trim(),
    );

    final result = await _bookingService.createBooking(booking);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text('Booking Submitted'),
            ],
          ),
          content: Text(
            'Your booking request has been submitted successfully! '
            'We will contact you shortly to confirm the details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Pop back to destination detail, then to main nav
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Navigate to BookingsScreen by switching tab
                // This will be handled by the main navigation
              },
              child: Text('View Booking'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Trek'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Destination Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.destination.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(widget.destination.location),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.destination.durationDays} Days',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'NPR ${widget.destination.price.toStringAsFixed(0)} per person',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Start Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Number of People
              TextFormField(
                initialValue: _numberOfPeople.toString(),
                decoration: InputDecoration(
                  labelText: 'Number of People',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of people';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1) {
                    return 'Please enter a valid number';
                  }
                  if (number > widget.destination.groupSizeMax) {
                    return 'Maximum group size is ${widget.destination.groupSizeMax}';
                  }
                  return null;
                },
                onChanged: (value) {
                  final number = int.tryParse(value);
                  if (number != null) {
                    setState(() => _numberOfPeople = number);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Contact Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Contact Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Special Requirements
              TextFormField(
                controller: _requirementsController,
                decoration: InputDecoration(
                  labelText: 'Special Requirements (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Dietary restrictions, medical conditions, etc.',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Total Price
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NPR ${(widget.destination.price * _numberOfPeople).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Booking Request',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
