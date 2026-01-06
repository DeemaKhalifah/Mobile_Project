import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_service.dart';
import 'service_details_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  final String? customerEmail;

  const CustomerMainScreen({super.key, this.customerEmail});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  late Future<List<Service>> servicesFuture;
  String? _customerEmail;
  bool _isLoadingEmail = true;

  @override
  void initState() {
    super.initState();
    servicesFuture = ApiService.getServices();
    _customerEmail = widget.customerEmail;

    if (_customerEmail == null || _customerEmail!.isEmpty) {
      _loadCustomerEmail();
    } else {
      _isLoadingEmail = false;
    }
  }

  Future<void> _loadCustomerEmail() async {
    final email = await SharedPreferencesService.getCustomerEmail();
    setState(() {
      _customerEmail = email;
      _isLoadingEmail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingEmail) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_customerEmail == null || _customerEmail!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Customer information not available"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        title: const Text("Car Wash Services"),
        backgroundColor: AppStyles.primaryVeryDarkColor,
      ),
      body: FutureBuilder<List<Service>>(
        future: servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppStyles.whiteColor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: AppStyles.errorTextStyle));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No services available", style: AppStyles.errorTextStyle));
          } else {
            final services = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(AppStyles.standardPadding10),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                String imageName = service.image.trim();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: AppStyles.cardShape,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppStyles.cardTopBorderRadius,
                        child: Image.asset(
                          "assets/images/$imageName",
                          width: double.infinity,
                          height: AppStyles.imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: AppStyles.imageHeight,
                              color: AppStyles.greyColor,
                              child: const Center(
                                  child: Icon(Icons.car_repair, size: AppStyles.iconSize, color: AppStyles.whiteColor)),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: AppStyles.serviceNameStyle,
                              ),
                            ),
                            Text(
                              "\$${service.price.toStringAsFixed(2)}",
                              style: AppStyles.servicePriceStyle,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailsScreen(
                                  service: service,
                                  customerEmail: _customerEmail!,
                                ),
                              ),
                            );
                          },
                          child: const Text("View Details"),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
