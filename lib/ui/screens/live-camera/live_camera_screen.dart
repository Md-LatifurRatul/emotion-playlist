// import 'package:camera/camera.dart'; // Make sure you added camera plugin
// import 'package:emo_music_app/controller/live_camera_emotion_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LiveCameraScreen extends StatefulWidget {
//   const LiveCameraScreen({super.key});

//   @override
//   State<LiveCameraScreen> createState() => _LiveCameraScreenState();
// }

// class _LiveCameraScreenState extends State<LiveCameraScreen> {
//   late LiveCameraEmotionProvider provider;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     // Init provider and camera once widget is built
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       provider = Provider.of<LiveCameraEmotionProvider>(context, listen: false);
//       await provider.initialize(); // init camera + model
//       provider.startDetection(); // start continuous detection
//       provider.addListener(_onEmotionDetected);
//       setState(() {
//         _isInitialized = true;
//       });
//     });
//   }

//   void _onEmotionDetected() {
//     final emotion = provider.detectedEmotion;
//     if (emotion.isNotEmpty) {
//       // Detected an emotion - navigate back and update home screen
//       provider.removeListener(_onEmotionDetected);

//       // Pass the detected emotion back to previous screen
//       Navigator.of(context).pop(emotion);
//     }
//   }

//   @override
//   void dispose() {
//     provider.stopDetection();

//     provider.removeListener(_onEmotionDetected);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(provider.cameraController!),
//           if (provider.detectedEmotion.isEmpty)
//             const Align(
//               alignment: Alignment.topCenter,
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   "Hold still, looking for face...",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           if (provider.detectedEmotion.isNotEmpty)
//             Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 color: Colors.black54,
//                 padding: const EdgeInsets.all(10),
//                 child: Text(
//                   provider.detectedEmotion.toUpperCase(),
//                   style: const TextStyle(color: Colors.white, fontSize: 24),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
