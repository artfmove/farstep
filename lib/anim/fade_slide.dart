import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FadeSlide extends StatefulWidget {
  final Object child;
  final double endXOffset;
  final double endYOffset;
  final double beginXOffset;
  final double beginYOffset;
  final bool isForward;
  final String type;
  const FadeSlide(
      {this.child,
      this.endXOffset,
      this.endYOffset,
      this.beginXOffset,
      this.beginYOffset,
      this.isForward,
      this.type});
  @override
  _FadeSlideState createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with TickerProviderStateMixin {
  AnimationController _controllerSlide;
  AnimationController _controllerFade;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controllerSlide = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _controllerFade = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
            begin: Offset(widget.beginXOffset == null ? 0 : widget.beginXOffset,
                widget.beginYOffset == null ? 0 : widget.beginYOffset),
            end: Offset(widget.endXOffset == null ? 0 : widget.endXOffset,
                widget.endYOffset == null ? 1 : widget.endYOffset))
        .animate(CurvedAnimation(
            curve: Curves.fastOutSlowIn, parent: _controllerSlide));

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllerFade, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controllerSlide.dispose();
    _controllerFade.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isForward) {
      if (widget.type == 'slide') _controllerSlide.forward();
      if (widget.type == 'fade') _controllerFade.forward();
      if (widget.type == 'both') {
        _controllerFade.forward();
        _controllerSlide.forward();
      }
    } else {
      if (widget.type == 'slide') _controllerSlide.reverse();
      if (widget.type == 'fade') _controllerFade.reverse();
      if (widget.type == 'both') {
        _controllerFade.reverse();
        _controllerSlide.reverse();
      }
    }
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
