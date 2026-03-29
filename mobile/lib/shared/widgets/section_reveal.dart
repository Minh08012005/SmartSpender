import 'package:flutter/material.dart';

class SectionReveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final Duration duration;
  final double beginYOffset;

  const SectionReveal({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.duration = const Duration(milliseconds: 360),
    this.beginYOffset = 0.05,
  });

  @override
  State<SectionReveal> createState() => _SectionRevealState();
}

class _SectionRevealState extends State<SectionReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : Offset(0, widget.beginYOffset),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
