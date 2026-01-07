import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
import 'service_details_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  final CustomerWallet? wallet;
  final String? customerEmail;

  const CustomerMainScreen({super.key, this.wallet, this.customerEmail});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  late Future<List<Service>> servicesFuture;

  @override
  void initState() {
    super.initState();
    servicesFuture = ApiService.getServices();
  }

  @override
  Widget build(BuildContext context) {
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
                                builder: (_) =>
                                    ServiceDetailsScreen(
                                      service: service,
                                      wallet: widget.wallet ?? CustomerWallet(
                                        cardNumber: "1111222233334444",
                                        cardHolder: "Customer",
                                        expiryDate: "12/28",
                                        cvv: "123",
                                        balance: 100.0,
                                      ),
                                      customerEmail: widget.customerEmail ?? '',
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
