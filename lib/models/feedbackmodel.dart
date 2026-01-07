class FeedbackModel {
  final int customerId;
  final int serviceId;
  final int rating;
  final String comment;

  FeedbackModel({
    required this.customerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "service_id": serviceId,
        "rating": rating,
        "comment": comment,
      };
}
