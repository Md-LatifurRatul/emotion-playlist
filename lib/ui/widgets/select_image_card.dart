import 'package:emo_music_app/controller/image_picker_provider.dart';
import 'package:flutter/material.dart';

class SelectImageCard extends StatelessWidget {
  const SelectImageCard({super.key, required this.imageCallActions});

  final ImagePickerProvider imageCallActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: Colors.limeAccent.shade400,
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              child: Icon(Icons.image, size: 50),
              onTap: () {
                imageCallActions.pickImage();
              },
              onLongPress: () {
                imageCallActions.captureCameraImage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
