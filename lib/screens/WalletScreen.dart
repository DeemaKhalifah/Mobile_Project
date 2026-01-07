// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load wallet: $e")),
      );
    }
  }

  Future<void> _addMoney() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        wallet!.addMoney(amount);
      });

      // Update in SQL via API
      try {
        await ApiService.updateWallet(widget.customerEmail, wallet!.balance);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added \$${amount.toStringAsFixed(2)}! Current balance: \$${wallet!.balance.toStringAsFixed(2)}",
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update wallet: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (wallet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
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
                initialValue: wallet!.cardNumber,
                decoration: AppStyles.filledInputDecoration.copyWith(labelText: "Card Number"),
                keyboardType: TextInputType.number,
                onSaved: (val) => cardNumber = val!,
                validator: (val) => val!.isEmpty ? "Enter card number" : null,
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                initialValue: wallet!.cardHolder,
                decoration: AppStyles.filledInputDecoration.copyWith(labelText: "Card Holder Name"),
                onSaved: (val) => cardHolder = val!,
                validator: (val) => val!.isEmpty ? "Enter card holder name" : null,
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: wallet!.expiryDate,
                      decoration: AppStyles.filledInputDecoration.copyWith(labelText: "Expiry Date (MM/YY)"),
                      onSaved: (val) => expiryDate = val!,
                      validator: (val) => val!.isEmpty ? "Enter expiry date" : null,
                    ),
                  ),
                  const SizedBox(width: AppStyles.smallSpacing),
                  Expanded(
                    child: TextFormField(
                      initialValue: wallet!.cvv,
                      decoration: AppStyles.filledInputDecoration.copyWith(labelText: "CVV"),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => cvv = val!,
                      validator: (val) => val!.isEmpty ? "Enter CVV" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                decoration: AppStyles.filledInputDecoration.copyWith(labelText: "Amount to Add"),
                keyboardType: TextInputType.number,
                onSaved: (val) => amount = double.tryParse(val!) ?? 0.0,
                validator: (val) => val!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: AppStyles.xlargeSpacing),
              ElevatedButton(
                style: AppStyles.walletButtonStyle,
                onPressed: _addMoney,
                child: const Text("Add Money", style: AppStyles.buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

