import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/parking_space.dart';
import '../services/parking_service.dart';
import '../widgets/text_styles.dart';
import 'styled_text_field.dart';

class EditParkingDialog extends StatelessWidget {
  final ParkingSpace space;
  final VoidCallback onUpdated;

  EditParkingDialog({
    super.key,
    required this.space,
    required this.onUpdated,
  });

  final _parkingService = ParkingService();

  @override
  Widget build(BuildContext context) {
    final _priceController = TextEditingController(text: space.pricePerHour.toString());
    final _slotsController = TextEditingController(text: space.availableSpots.toString());
    final _upiController = TextEditingController(text: space.upiId);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Parking Space', style: headerStyle),
              const SizedBox(height: 20),
              StyledTextField(
                label: 'Price per hour',
                controller: _priceController,
                inputType: TextInputType.number,
                textStyle: subtitleStyle,
              ),
              const SizedBox(height: 16),
              StyledTextField(
                label: 'Available spots',
                controller: _slotsController,
                inputType: TextInputType.number,
                textStyle: subtitleStyle,
              ),
              const SizedBox(height: 16),
              StyledTextField(
                label: 'Owner UPI ID',
                controller: _upiController,
                inputType: TextInputType.text,
                textStyle: subtitleStyle,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final newPrice = double.tryParse(_priceController.text) ?? space.pricePerHour;
                      final newSlots = int.tryParse(_slotsController.text) ?? space.availableSpots;
                      final newUpi = _upiController.text.trim();

                      await _parkingService.updateParkingSpace(
                        space.id,
                        pricePerHour: newPrice,
                        availableSpots: newSlots,
                        upiId: newUpi,
                      );

                      Navigator.pop(context);
                      onUpdated();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: buttonTextStyle,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void showEditParkingDialog(BuildContext context, ParkingSpace space, VoidCallback onUpdated) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Edit",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return EditParkingDialog(space: space, onUpdated: onUpdated);
    },
    transitionBuilder: (context, animation, _, child) {
      final curvedValue = Curves.easeInOutBack.transform(animation.value) - 1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
        child: Opacity(opacity: animation.value, child: child),
      );
    },
  );
}
