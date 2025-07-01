import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final TextStyle textStyle;

  const DashboardStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(label, style: textStyle),
      ],
    );
  }
}
