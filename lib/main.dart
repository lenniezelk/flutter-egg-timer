import 'dart:async';

import 'package:egg_timer/egg_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

enum EggType { soft, hard }

class _HomeViewState extends State<HomeView> {
  EggType eggType;
  Map<EggType, int> cookPeriod = {EggType.hard: 11, EggType.soft: 6};
  int remainingTime;
  bool counting = false;
  Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eggType = EggType.soft;
    _resetRemainingTime();
  }

  _resetRemainingTime() {
    setState(() {
      remainingTime = cookPeriod[eggType] * 60;
    });
  }

  _twoDigits(int n) {
    return n.toString().padLeft(2, "0");
  }

  _renderClock() {
    final duration = Duration(seconds: remainingTime);
    final minutes = _twoDigits(duration.inMinutes.remainder(60));
    final seconds = _twoDigits(duration.inSeconds.remainder(60));
    return Text(
      "$minutes:$seconds",
      style: TextStyle(fontSize: 50.0, fontFamily: 'Square'),
    );
  }

  Widget _renderEggTypeSelect() {
    return Center(
      child: DropdownButton<EggType>(
          value: eggType,
          items: [EggType.hard, EggType.soft].map((e) {
            final txt = e == EggType.hard ? 'Hard Boiled' : 'Soft Boiled';
            return DropdownMenuItem<EggType>(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    txt,
                    style: TextStyle(fontSize: 20.0),
                  ),
                ));
          }).toList(),
          onChanged: (value) {
            setState(() {
              eggType = value;
              _cancelTimer();
              _resetRemainingTime();
            });
          }),
    );
  }

  _renderPlayIcon() {
    var icon = Icons.play_arrow;
    if (counting) {
      icon = Icons.stop;
    }
    return Icon(
      icon,
      size: 40.0,
    );
  }

  _cancelTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    setState(() {
      counting = false;
    });
  }

  _tick() {
    setState(() {
      remainingTime -= 1;
      if (remainingTime <= 0) {
        _cancelTimer();
        _resetRemainingTime();
      }
    });
  }

  _startTimer() {
    if (counting) {
      _cancelTimer();
      _resetRemainingTime();
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        _tick();
      });
      setState(() {
        counting = true;
      });
    }
  }

  Widget _renderEggImage() {
    String imgPath = 'assets/images/hard_egg.png';
    if (eggType == EggType.hard) {
      imgPath = 'assets/images/soft_egg.png';
    }

    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = Color.fromARGB(
        80, primaryColor.red, primaryColor.green, primaryColor.blue);
    final totalTime = cookPeriod[eggType] * 60;
    final percent = remainingTime / totalTime;

    return CustomPaint(
      foregroundPainter: EggOverlay(bgColor: bgColor, percent: percent),
      child: CircleAvatar(
        radius: 150.0,
        backgroundColor: Colors.white10,
        child: Image.asset(imgPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _startTimer,
        child: _renderPlayIcon(),
      ),
      appBar: AppBar(
        title: Text("Egg Timer"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _renderEggTypeSelect(),
            SizedBox(
              height: 30.0,
            ),
            _renderClock(),
            SizedBox(
              height: 30.0,
            ),
            _renderEggImage()
          ],
        ),
      ),
    );
  }
}
