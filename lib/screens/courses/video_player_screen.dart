import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../data/models/resource.dart';

/// Screen for viewing video resources (F2.2.1)
class VideoPlayerScreen extends StatefulWidget {
  final Resource resource;
  final int courseId;
  final String userId;

  const VideoPlayerScreen({
    super.key,
    required this.resource,
    required this.courseId,
    required this.userId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _startTime;
  int _watchedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.resource.url == null || widget.resource.url!.isEmpty) {
        setState(() {
          _errorMessage = 'URL de la vidéo non disponible';
          _isLoading = false;
        });
        return;
      }

      // Initialize video player
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.resource.url!),
      );

      await _videoPlayerController!.initialize();

      // Create Chewie controller for better UI
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).colorScheme.primary,
          handleColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Erreur de lecture',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Listen to position updates to track watch time
      _videoPlayerController!.addListener(_updateWatchTime);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement de la vidéo: $e';
        _isLoading = false;
      });
    }
  }

  void _updateWatchTime() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
      final position = _videoPlayerController!.value.position;
      _watchedSeconds = position.inSeconds;
    }
  }

  Future<void> _saveProgress() async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final timeSpent = endTime.difference(_startTime!).inSeconds;

    print('📊 Video watched: ${widget.resource.title}');
    print('⏱️ Time spent: $timeSpent seconds');
    print('📹 Video position: $_watchedSeconds seconds');

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    // Update progress with time spent
    await courseProvider.updateProgressWithUUID(
      userId: widget.userId,
      courseId: widget.courseId,
      currentResourceId: widget.resource.id,
      additionalTimeSpentSeconds: timeSpent,
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Save progress when leaving
    _videoPlayerController?.removeListener(_updateWatchTime);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.resource.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Retour'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Video Player
                    Expanded(
                      child: Center(
                        child: _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const CircularProgressIndicator(),
                      ),
                    ),
                    
                    // Video Info
                    Container(
                      color: Colors.grey.shade900,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.resource.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.resource.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.resource.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (widget.resource.durationSeconds != null) ...[
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.resource.formattedDuration,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
