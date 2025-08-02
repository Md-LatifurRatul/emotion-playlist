import 'dart:io';

import 'package:flutter/material.dart';

class MoodDetectionButton extends StatelessWidget {
  const MoodDetectionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.image,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final File? image;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = isLoading ? null : onTap;
    final effectiveOnLongPress = isLoading ? null : onLongPress;

    return GestureDetector(
      onTap: effectiveOnTap,
      onLongPress: effectiveOnLongPress,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),

            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
