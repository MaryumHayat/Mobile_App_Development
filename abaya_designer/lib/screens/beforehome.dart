import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart'; 
import 'main_navigation.dart';

class BeforeHome extends StatefulWidget {
  const BeforeHome({super.key});

  @override
  State<BeforeHome> createState() => _BeforeHomeState();
}
class BottomCropClipper extends CustomClipper<Rect> {
  final double cropPercentage;
  BottomCropClipper(this.cropPercentage); 
  @override
  Rect getClip(Size size) { // size is the full size of the video
    return Rect.fromLTRB(0, 0, size.width, size.height * (1 - cropPercentage));
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true; // Always reclip to ensure the video is cropped correctly if the size changes
}

class _BeforeHomeState extends State<BeforeHome> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() { 
    super.initState(); // The order of initialization is crucial to ensure both audio and video work seamlessly without interfering with each other.

    // 1. Setup Audio
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();

    // 2. Setup Video 
    _videoController = VideoPlayerController.asset(
      'assets/images/beforevideo.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _initializeVideo();
  }

  // Separated logic to ensure a clean async flow
  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      if (mounted) {
        await _videoController.setLooping(true);
        await _videoController.setVolume(0.0);
        await _videoController.play();
        setState(() {}); // Rebuild to show initialized video
      }

      // Force a UI update loop specifically for the video frames
      _videoController.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint("Video Init Error: $e");
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.setSource(AssetSource('images/beforeaudio.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(() {}); // Clean up listener
    _videoController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToShop() {
    _scrollController.animateTo(
      MediaQuery.of(context).size.height,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final List<Widget> carouselItems = [
      Image.asset('assets/images/hijab.png', fit: BoxFit.cover),
      Image.asset('assets/images/sale.png', fit: BoxFit.cover),
      Image.asset('assets/images/abaya.png', fit: BoxFit.cover),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Ensures the entire content is scrollable, especially for smaller screens
        controller: _scrollController,
        physics: const ClampingScrollPhysics(), 
        child: Column(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Stack(
                children: [
                  _videoController.value.isInitialized
                      ? SizedBox.expand(
                          child: ClipRect(
                            clipper: BottomCropClipper(
                                0.05), // Crops from the bottom
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController.value.size.width,
                                height: _videoController.value.size.height,
                                child: VideoPlayer(_videoController),
                              ),
                            ),
                          ),
                        )
                      : Container(color: Colors.black),
                  SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 40, left: 70),
                          child: Text(
                            "ABAYA DESIGNER",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              letterSpacing: 3,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 15, color: Colors.black54)
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 545, left: 80),
                          child: Text(
                            "Embrace Elegance with Every Step.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'MedievalSharp-Regular',
                              shadows: [
                                Shadow(blurRadius: 15, color: Colors.black54)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30, left: 60),
                          child: IconButton(
                            onPressed: _scrollToShop,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SECTION 2
            Container(
              padding: const EdgeInsets.symmetric(vertical: 70),
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 135.0,
                      autoPlay: true,
                      viewportFraction: 0.85, // Shows a bit of the next item to indicate more content
                    ),
                    items: carouselItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: item),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(initialIndex: 0),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 22),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text("DISCOVER SHOP"),
                  ),
                   const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement( // Replaces the current screen with the My Studio screen, preventing back navigation to the beforehome
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(initialIndex: 1), // Opens My Studio
                          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 22),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    child: const Text("Design Your Abaya",style: TextStyle(letterSpacing: 3),),
                  ),
                ],
              ),
            ),
            // FOOTER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              color: const Color.fromARGB(255, 141, 85, 104),
              width: double.infinity,
              child: const Column(
                children: [
                  Divider(
                      thickness: 1, color: Color.fromARGB(255, 255, 255, 255)),
                  SizedBox(height: 20),
                  Text("ABAYA DESIGNER",
                      style: TextStyle(color: Colors.white, letterSpacing: 4)),
                  SizedBox(height: 20),
                  Text("Lane 1, Westridge III, Rawalpindi, Pakistan",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                  SizedBox(height: 40),
                  Text("© 2026 ABAYA DESIGNER. All Rights Reserved.",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}