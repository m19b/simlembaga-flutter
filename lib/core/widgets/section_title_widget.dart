import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final double paddingBottom;

  const SectionTitleWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.paddingBottom = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: paddingBottom),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
