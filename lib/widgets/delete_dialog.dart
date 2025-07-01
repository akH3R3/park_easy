import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required Future<void> Function() onConfirm,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 300),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to delete this slot?'),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deletion Cancelled'),
                      backgroundColor: Colors.blueGrey,
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onConfirm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Slot deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
