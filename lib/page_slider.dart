library page_slider;

import 'package:flutter/material.dart';

class PageSlider extends StatefulWidget {
  PageSlider({
    super.key,
    required this.pages,
    this.duration = const Duration(milliseconds: 300),
    this.initialPage = 0,
    this.onFinished,
    this.alignment = Alignment.center,
    this.fit = StackFit.loose,
  });

  final List<Widget> pages;
  final Duration duration;
  final int initialPage;
  final VoidCallback? onFinished;
  final AlignmentGeometry alignment;
  final StackFit fit;

  PageSliderState createState() => PageSliderState();
}

class PageSliderState extends State<PageSlider> with TickerProviderStateMixin {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  late List<Animation<Offset>> _positions;
  late List<AnimationController> _controllers;

  @override
  void initState() { 
    super.initState();
    _currentPage = widget.initialPage;

    _controllers = List.generate(
      widget.pages.length, 
      (i) => AnimationController(
        vsync: this,
        duration: widget.duration,
        lowerBound: 0,
        upperBound: 1,
        value: i == _currentPage
          ? 0.5
          : (i > _currentPage ? 1 : 0),
      )
    );

    _positions = _controllers
      .map((controller) =>
        Tween(
          begin: Offset(-1, 0), 
          end: Offset(1, 0)
        )
        //.chain(CurveTween(curve: Curves.easeInCubic))
        .animate(controller)
      ).toList();
  }

  bool get hasNext => (_currentPage < widget.pages.length - 1);
  bool get hasPrevious => (_currentPage > 0);


  void setPage(int page) {
    assert(page >= 0 || page < widget.pages.length);
    while (_currentPage < page) next();
    while (_currentPage > page) previous();
  }

  void next() {
    if (!hasNext) {
      widget.onFinished?.call();
      return;
    }

    _controllers[_currentPage].animateTo(0);
    _controllers[_currentPage + 1].animateTo(0.5);
    setState(() {
      _currentPage += 1;
    });
  }

  void previous() {
    if (!hasPrevious) return;

    _controllers[_currentPage].animateTo(1);
    _controllers[_currentPage - 1].animateTo(0.5);
    setState(() {
      _currentPage -= 1;
    });
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      fit: widget.fit,
      children: widget.pages.asMap().map((i, page) =>
        MapEntry(
          i, 
          SlideTransition(
            position: _positions[i],
            child: Center(child: page),
          )
        )
      ).values.toList(),
    );
  }
}