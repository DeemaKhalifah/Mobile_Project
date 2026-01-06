import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_service.dart';
import 'paymentscreen.dart';

class BookingForm extends StatefulWidget {
  final Service? service;
  final CustomerWallet wallet;
  final String customerEmail;
  final Booking? existingBooking;
  final bool isUpdate;

  const BookingForm({
    super.key,
    this.service,
    required this.wallet,
    required this.customerEmail,
    this.existingBooking,
    this.isUpdate = false,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController locationController;
  late TextEditingController notesController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController carModelController;
  late TextEditingController carPlateController;

  @override
  void initState() {
    super.initState();
    locationController =
        TextEditingController(text: widget.existingBooking?.location ?? '');
    notesController =
        TextEditingController(text: widget.existingBooking?.notes ?? '');
    dateController =
        TextEditingController(text: widget.existingBooking?.bookingDate ?? '');
    timeController =
        TextEditingController(text: widget.existingBooking?.bookingTime ?? '');
    carModelController =
        TextEditingController(text: widget.existingBooking?.carModel ?? '');
    carPlateController =
        TextEditingController(text: widget.existingBooking?.carPlate ?? '');
  }

  @override
  void dispose() {
    locationController.dispose();
    notesController.dispose();
    dateController.dispose();
    timeController.dispose();
    carModelController.dispose();
    carPlateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').tryParse(dateController.text) ?? DateTime.now()
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (timeController.text.isNotEmpty) {
      try {
        final timeParts = timeController.text.split(':');
        if (timeParts.length >= 2) {
          initialTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (_) {}
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      timeController.text = DateFormat('HH:mm:ss').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpdate
            ? "Update Booking"
            : "Book ${widget.service?.name ?? ''}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  validator: (v) => v!.isEmpty ? "Enter location" : null,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: "Notes"),
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Select Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                  validator: (v) => v!.isEmpty ? "Pick a date" : null,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Select Time",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _pickTime,
                  validator: (v) => v!.isEmpty ? "Pick a time" : null,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                TextFormField(
                  controller: carModelController,
                  decoration: const InputDecoration(labelText: "Car Model"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter car model" : null,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                TextFormField(
                  controller: carPlateController,
                  decoration: const InputDecoration(labelText: "Car Plate Number"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter plate number" : null,
                ),
                const SizedBox(height: AppStyles.largeSpacing),
                ElevatedButton(
                  style: AppStyles.darkButtonStyle,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isUpdate && widget.existingBooking != null) {
                        // Update existing booking
                        final updatedBooking = Booking(
                          id: widget.existingBooking!.id,
                          customerEmail: widget.customerEmail,
                          serviceName: widget.existingBooking!.serviceName,
                          location: locationController.text,
                          notes: notesController.text,
                          bookingDate: dateController.text,
                          bookingTime: timeController.text,
                          carModel: carModelController.text,
                          carPlate: carPlateController.text,
                        );

                        try {
                          final result =
                              await ApiService.updateBooking(updatedBooking);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    result['message'] ?? 'Booking updated successfully')),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Update failed: $e")),
                          );
                        }
                      } else if (widget.service != null) {
                        // Create new booking
                        final newBooking = Booking(
                          customerEmail: widget.customerEmail,
                          serviceName: widget.service!.name,
                          location: locationController.text,
                          notes: notesController.text,
                          bookingDate: dateController.text,
                          bookingTime: timeController.text,
                          carModel: carModelController.text,
                          carPlate: carPlateController.text,
                        );

                        try {
                          final result = await ApiService.createBookingWithCar(
                            newBooking,
                            carModelController.text,
                            carPlateController.text,
                          );

                          if (result['status'] == true) {
                            final customerId =
                                await SharedPreferencesService.getCustomerId() ?? 0;

                            Navigator.pop(context, true);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  serviceName: widget.service!.name,
                                  price: widget.service!.price,
                                  wallet: widget.wallet,
                                  customerId: customerId,
                                  serviceId: widget.service!.id,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      result['message'] ?? 'Booking failed')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                      widget.isUpdate ? "Update Booking" : "Confirm Booking"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}