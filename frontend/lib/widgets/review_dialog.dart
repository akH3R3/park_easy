import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showReviewDialog(BuildContext context) async {
  double tempRating = 3.0;
  String comment = '';

  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate this parking:'),
            StatefulBuilder(
              builder: (context, setState) => Slider(
                value: tempRating,
                min: 0,
                max: 5,
                divisions: 10,
                label: tempRating.toString(),
                onChanged: (value) => setState(() => tempRating = value),
              ),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Comment'),
              onChanged: (val) => comment = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'rating': tempRating,
              'comment': comment,
            }),
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
