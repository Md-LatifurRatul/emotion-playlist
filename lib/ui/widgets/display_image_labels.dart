import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class DisplayImageLabels extends StatelessWidget {
  const DisplayImageLabels({
    super.key,
    required this.selectedImage,
    required this.detectedLabels,
  });

  final File? selectedImage;
  final List<ImageLabel> detectedLabels;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: selectedImage == null
          ? Text(
              'Pick an image to see labels.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            )
          : detectedLabels.isEmpty
          ? Text(
              'No labels detected for this image.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detectedLabels.map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Label: ${label.label}, Confidence: ${label.confidence.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
