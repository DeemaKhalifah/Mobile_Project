import 'package:flutter/material.dart';
import '../models/feedbackmodel.dart';
import '../services/api_service.dart';
import '../styles/strings.dart';

class FeedbackScreen extends StatefulWidget {
  final int customerId;
  final int serviceId;

  const FeedbackScreen({
    super.key,
    required this.customerId,
    required this.serviceId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 40,
      ),
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
    );
  }

  void submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.error)));
      return;
    }

    final feedback = FeedbackModel(
      customerId: widget.customerId,
      serviceId: widget.serviceId,
      rating: _rating,
      comment: _commentController.text,
    );

    final success = await ApiService.submitFeedback(feedback);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? AppStrings.success : AppStrings.error)),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.feedback)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("How was the service?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => buildStar(i + 1)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Optional comment",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text("Submit Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
