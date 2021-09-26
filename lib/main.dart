import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Easel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Easel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ClearNotifier _clearedNotifier;

  @override
  void initState() {
    super.initState();
    _clearedNotifier = ClearNotifier();
  }

  @override
  void dispose() {
    _clearedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _clearedNotifier.clear();
            },
          ),
        ],
      ),
      body: Easel(notifier: _clearedNotifier),
    );
  }
}

class ClearNotifier extends ChangeNotifier {
  void clear() => notifyListeners();
}

class Easel extends StatefulWidget {
  final ClearNotifier? notifier;

  const Easel({
    this.notifier,
    Key? key,
  }) : super(key: key);

  @override
  _EaselState createState() => _EaselState();
}

class _EaselState extends State<Easel> {
  final points = <List<Offset>>[];
  ClearNotifier? notifier;

  @override
  void initState() {
    super.initState();
    subscribe(widget.notifier);
  }

  @override
  void didUpdateWidget(covariant Easel oldWidget) {
    super.didUpdateWidget(oldWidget);
    subscribe(widget.notifier);
  }

  @override
  void dispose() {
    notifier?.removeListener(clear);
    super.dispose();
  }

  void subscribe(ClearNotifier? notifier) {
    if (this.notifier == notifier) return;

    this.notifier?.removeListener(clear);
    this.notifier = notifier;
    this.notifier?.addListener(clear);
  }

  void clear() {
    points.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final points in this.points)
          CustomPaint(
            painter: EaselPainter(points.toList()),
            size: Size.infinite,
          ),
        Positioned.fill(
          child: GestureDetector(
            onPanDown: (details) {
              points.add([]);
              points.last.add(details.localPosition);
              setState(() {});
            },
            onPanUpdate: (details) {
              points.last.add(details.localPosition);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}

class EaselPainter extends CustomPainter {
  final List<Offset> points;
  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3.0;

  EaselPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(
      points.length == 1 ? PointMode.points : PointMode.polygon,
      points,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! EaselPainter) {
      return true;
    }
    return points.length != oldDelegate.points.length;
  }
}
