class CustomerWallet {
  String cardNumber;
  String cardHolder;
  String expiryDate;
  String cvv;
  double balance;
  int? userId; 

  CustomerWallet({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.balance,
    this.userId,
  });

  factory CustomerWallet.fromJson(Map<String, dynamic> json) {
    return CustomerWallet(
      cardNumber: json['card_number'] ?? '',
      cardHolder: json['card_holder'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      cvv: json['cvv'] ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      userId: json['user_id'] != null ? int.parse(json['user_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "card_number": cardNumber,
      "card_holder": cardHolder,
      "expiry_date": expiryDate,
      "cvv": cvv,
      "balance": balance,
      "user_id": userId,
    };
  }

  void addMoney(double amount) {
    balance += amount;
  }

  bool pay(double amount) {
    if (balance >= amount) {
      balance -= amount;
      return true;
    }
    return false;
  }
}
