// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class SyncingAnimation extends StatefulWidget {
  const SyncingAnimation({super.key});

  @override
  _SyncingAnimationState createState() => _SyncingAnimationState();
}

class _SyncingAnimationState extends State<SyncingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // This makes it loop indefinitely.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.sync,
        size: 15.0,
        color: Colors.white,
      ),
    );
  }
}
