// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../styles/strings.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  final String customerEmail;

  const WalletScreen({super.key, required this.customerEmail});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _formKey = GlobalKey<FormState>();
  CustomerWallet? wallet;

  String cardNumber = "";
  String cardHolder = "";
  String expiryDate = "";
  String cvv = "";
  double amount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final loadedWallet = await ApiService.getWallet(widget.customerEmail);

      setState(() {
        wallet = loadedWallet;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load wallet: $e")));
    }
  }

  Future<void> _addMoney() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        wallet!.addMoney(amount);
      });

      // Update wallet in SQL via API with card details if provided
      try {
        await ApiService.updateWallet(
          widget.customerEmail,
          wallet!.balance,
          cardNumber: cardNumber.isNotEmpty ? cardNumber : null,
          cardHolder: cardHolder.isNotEmpty ? cardHolder : null,
          expiryDate: expiryDate.isNotEmpty ? expiryDate : null,
          cvv: cvv.isNotEmpty ? cvv : null,
        );

        // Update local wallet object with card details
        if (cardNumber.isNotEmpty) wallet!.cardNumber = cardNumber;
        if (cardHolder.isNotEmpty) wallet!.cardHolder = cardHolder;
        if (expiryDate.isNotEmpty) wallet!.expiryDate = expiryDate;
        if (cvv.isNotEmpty) wallet!.cvv = cvv;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added \$${amount.toStringAsFixed(2)}! Current balance: \$${wallet!.balance.toStringAsFixed(2)}",
            ),
          ),
        );

        // Reload wallet to get latest from database
        await _loadWallet();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update wallet: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (wallet == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wallet),
        backgroundColor: AppStyles.primaryVeryDarkColor,
      ),
      backgroundColor: AppStyles.primaryLightColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.standardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Wallet Balance: \$${wallet!.balance.toStringAsFixed(2)}",
                style: AppStyles.walletBalanceStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppStyles.xlargeSpacing),
              TextFormField(
                initialValue: wallet!.cardNumber.isNotEmpty
                    ? wallet!.cardNumber
                    : '',
                decoration: AppStyles.filledInputDecoration.copyWith(
                  labelText: AppStrings.cardNumber,
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => cardNumber = val ?? '',
                validator: null, // Card number is optional
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                initialValue: wallet!.cardHolder.isNotEmpty
                    ? wallet!.cardHolder
                    : '',
                decoration: AppStyles.filledInputDecoration.copyWith(
                  labelText: AppStrings.cardHolderName,
                ),
                onSaved: (val) => cardHolder = val ?? '',
                validator: null, // Card holder is optional
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: wallet!.expiryDate.isNotEmpty
                          ? wallet!.expiryDate
                          : '',
                      decoration: AppStyles.filledInputDecoration.copyWith(
                        labelText: AppStrings.expiryDate,
                      ),
                      onSaved: (val) => expiryDate = val ?? '',
                      validator: null, // Expiry date is optional
                    ),
                  ),
                  const SizedBox(width: AppStyles.smallSpacing),
                  Expanded(
                    child: TextFormField(
                      initialValue: wallet!.cvv.isNotEmpty ? wallet!.cvv : '',
                      decoration: AppStyles.filledInputDecoration.copyWith(
                        labelText: AppStrings.cvv,
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => cvv = val ?? '',
                      validator: null, // CVV is optional
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                decoration: AppStyles.filledInputDecoration.copyWith(
                  labelText: "Amount to Add",
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => amount = double.tryParse(val!) ?? 0.0,
                validator: (val) =>
                    val!.isEmpty ? AppStrings.fieldRequired : null,
              ),
              const SizedBox(height: AppStyles.xlargeSpacing),
              ElevatedButton(
                style: AppStyles.walletButtonStyle,
                onPressed: _addMoney,
                child: const Text(
                  AppStrings.addMoney,
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
