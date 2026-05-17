import 'dart:async';
import 'package:abaya_designer/screens/login_page.dart';
import 'package:abaya_designer/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late VideoPlayerController _controller;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Video
    _controller = VideoPlayerController.asset('assets/images/splashvideo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setVolume(0.5);
        _controller.play();
      });

    // 2. Start the 6-second timer for the transition
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isFinished = true;
        });
      }
    });
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: TweenAnimationBuilder<double>(
        // Tween goes from 0 (Video focused) to 1 (UI focused)
        tween: Tween<double>(begin: 0.0, end: _isFinished ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 1200), // Smooth fade duration
        builder: (context, value, child) {
          return Stack(
            children: <Widget>[
              // BACKGROUND UI (Fades In)
              Opacity(
                opacity: value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/splash.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: 1.0 - value,
                child: IgnorePointer( // Ignore pointer events when the video is playing
                  ignoring: _isFinished,
                  child: SizedBox.expand(
                    child: _controller.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          )
                        : Container(color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                bottom: 30 + (20 * (1 - value)), // Slight slide up effect
                left: 50,
                right: 50,
                child: Opacity(
                  opacity: value,
                  child: IgnorePointer(
                    ignoring: !_isFinished,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Login Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(204, 80, 56, 56),
                            minimumSize: Size(size.width, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sign Up Button
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            minimumSize: Size(size.width, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupPage()),
                            );
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}