import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Assistant3DWidget extends StatelessWidget {
  const Assistant3DWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: ModelViewer(
        src: 'assets/3d/businesswoman.glb', // your GLB
        alt: 'Aromair Assistant',
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.transparent,
        // ar: true,  // enable only if you use AR
        // iosSrc: 'assets/3d/assistant.usdz', // optional for iOS AR
      ),
    );
  }
}
