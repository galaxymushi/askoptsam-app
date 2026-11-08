import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import 'camera_shell.dart';
import 'eye_ui.dart';

/// The blue dashed camera window from the Eye mockup, filled with the live
/// preview and a spoken instruction.
class EyeCameraBox extends StatelessWidget {
  const EyeCameraBox({
    super.key,
    required this.controller,
    required this.hint,
    this.height = 250,
    this.square = false,
  });

  final CameraController controller;
  final String hint;
  final double height;
  final bool square;

  @override
  Widget build(BuildContext context) {
    // The window runs nearly edge to edge even though the page content is
    // inset, so more of the scene fits in the frame.
    final width = MediaQuery.sizeOf(context).width - 16;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OverflowBox(
        minWidth: width,
        maxWidth: width,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: EyeColors.blueDeep,
            borderRadius: BorderRadius.circular(26),
          ),
          child: DashedFrame(
            radius: 20,
            color: EyeColors.ice,
            stroke: 3.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreviewFill(controller: controller),
                if (square)
                  Center(
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        border: Border.all(color: EyeColors.white, width: 3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                Center(child: CameraHint(hint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
