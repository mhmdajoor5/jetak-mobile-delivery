// lib/views/splash_screen.dart (or wherever your UI file is)
import 'package:deliveryboy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:video_player/video_player.dart';

import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart'; // Keep this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  late SplashScreenController _con;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoInitializationAttempted = false;

  SplashScreenState() : super(SplashScreenController()) {
    _con = (controller as SplashScreenController?)!;
  }

  @override
  void initState() {
    super.initState();
    _con.progress.addListener(_handleProgressUpdates);
    _initializeVideo();
  }

  void _initializeVideo() async {
    print('🎬 Starting video initialization...');
    print('🎬 Looking for video at: assets/img/splach.mp4');
    
    // Add delay to ensure video plays for minimum time
    await Future.delayed(Duration(seconds: 1));
    
    // Check if video file exists
    try {
      _videoController = VideoPlayerController.asset('assets/img/splach.mp4');
      print('🎬 Video controller created');
      
      await _videoController!.initialize();
      print('🎬 Video initialized successfully');
      print('🎬 Video duration: ${_videoController!.value.duration}');
      print('🎬 Video size: ${_videoController!.value.size}');
      print('🎬 Video aspect ratio: ${_videoController!.value.aspectRatio}');
      
      await _videoController!.setLooping(true);
      print('🎬 Video set to loop');
      
              await _videoController!.play();
        print('🎬 Video started playing');
        
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          print('🎬 Video splash screen activated');
          
          // Force rebuild to show video
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {});
            }
          });
          
          // Ensure video plays for full duration
          print('🎬 Video will play for 9 seconds');
        }
    } catch (e) {
      print('❌ Error initializing video: $e');
      print('🖼️ Falling back to logo image');
      print('📁 Please make sure splach.mp4 exists in assets/img/ folder');
      print('📁 Video should be at: assets/img/splach.mp4');
      // Fallback to logo image if video fails
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _handleProgressUpdates() {
    double totalProgress = 0; // Initialize total progress to 0
    for (var progress in _con.progress.value.values) {
      totalProgress += progress;
    }

    // Your original logic for navigation
    if (totalProgress >= 100) { // Changed from 59 to 100 for clarity based on your progress map values
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    // Ensure the context is still valid before navigating
    if (!mounted) return;

    // Add minimum delay to ensure video plays for full duration
    await Future.delayed(Duration(seconds: 9));

    try {
      if (currentUser.value.apiToken == null) {
        Navigator.of(context).pushReplacementNamed('/Login');
      } else {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
      }
    } catch (e) {
      // It's generally better to show an error message on the current screen
      // or handle this more gracefully, rather than just a snackbar that might disappear.
      // For a splash screen, if navigation fails due to internet,
      // you might want to show a retry button or a persistent error message.
      if (mounted) { // Check mounted again before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).verify_your_internet_connection),
        ));
      }
    }
  }

  @override
  void dispose() {
    _con.progress.removeListener(_handleProgressUpdates);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only print video status once during initialization
    try {
      return Scaffold(
        key: _con.scaffoldKey,
        body: _buildVideoSplash(),
      );
        } catch (e) {
      print('❌ Error in build: $e');
      // Fallback to video screen
      return Scaffold(
        key: _con.scaffoldKey,
        body: Container(
          color: Colors.black,
          child: Center(
            child: VideoPlayer(VideoPlayerController.asset('assets/img/splach.mp4')),
          ),
        ),
      );
    }
  }

    Widget _buildVideoSplash() {
    try {
      // Always try to show video, even if not fully initialized
      if (_videoController != null) {
        print('🎬 Building video splash - Showing video');
        return Container(
          color: Colors.black,
          child: Center(
            child: _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : VideoPlayer(_videoController!),
          ),
        );
      }
    } catch (e) {
      print('❌ Error in _buildVideoSplash: $e');
    }
    
    print('🎬 Building video splash - Creating new controller');
    // Create new video controller if none exists
    try {
      _videoController = VideoPlayerController.asset('assets/img/splach.mp4');
      return Container(
        color: Colors.black,
        child: Center(
          child: VideoPlayer(_videoController!),
        ),
      );
    } catch (e) {
      print('❌ Error creating video controller: $e');
      return Container(
        color: Colors.black,
      );
    }
  }


}