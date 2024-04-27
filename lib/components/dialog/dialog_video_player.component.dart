import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void showVideoDialog(BuildContext context, String videoUrl) {
  final VideoPlayerController controller =
      VideoPlayerController.networkUrl(Uri.parse(videoUrl));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              Positioned(
                child: IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 64.0,
                  ),
                  onPressed: () {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  },
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  controller.initialize().then((_) {
    // Ensure the first frame is shown after the video is initialized.
    controller.play();
  });
}
