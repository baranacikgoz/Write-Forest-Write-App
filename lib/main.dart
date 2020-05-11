import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppHomeState();
  }
}

class _MyAppHomeState extends State<MyAppHome> {
  String userName = "";
  int typedCharLength = 0;
  String lorem =
      "                          Lorem ipsum dolor sit amet, consectetur adipiscing elit. In dignissim eleifend enim, eu aliquam justo scelerisque rutrum. Nunc consequat velit a nulla consequat, ut ultrices eros auctor. Donec auctor ante augue, vitae maximus dui egestas vitae. Phasellus a eros eget mi tincidunt consequat. Donec blandit vehicula ex, vitae finibus tellus lobortis pulvinar. Duis nec ligula quis tellus convallis ornare. Donec id enim placerat, lobortis ligula ut, eleifend arcu. Nullam vehicula fermentum leo. Suspendisse feugiat dolor eu metus aliquam egestas. "
          .toLowerCase()
          .replaceAll(",", "");
  var shownWidget;
  int step = 0;

  int lastTypedAt;
  void updateLastTypedAt() {
    this.lastTypedAt = new DateTime.now().millisecondsSinceEpoch;
  }

  void onType(String value) {
    updateLastTypedAt();
    String trimmedValue = lorem.trimLeft();

    setState(() {
      if (trimmedValue.indexOf(value) != 0)
        step = 2;
      else
        setState(() {
          typedCharLength = value.length;
        });
    });
  }

  void onUserNameType(String userName) {
    setState(() {
      this.userName = userName;
    });
  }

  void onStartClick() {
    setState(() {
      updateLastTypedAt();
      step++;
    });

    var timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;

      //Game over
      setState(() {
        if (step == 1 && now - lastTypedAt > 4000) {
          step++;
        } 
    });
    if (step != 1) {
          http.post("https://write-forest-write-api.herokuapp.com/users/score",
              body: {
                'userName': userName,
                'score': typedCharLength.toString()
              });

          timer.cancel();
        }
      });
  }

  void tryAgain() {
    setState(() {
      step = 0;
      typedCharLength = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (step == 0)
      shownWidget = <Widget>[
        Text("Welcome to the game. Ready ?"),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: onUserNameType,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Name"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: RaisedButton(
            child: Text("Start !"),
            onPressed: userName.length == 0 ? null : onStartClick,
          ),
        )
      ];
    else if (step == 1)
      shownWidget = <Widget>[
        Text("Score : $typedCharLength"),
        Container(
          height: 40,
          child: Marquee(
            text: lorem,
            style: TextStyle(fontSize: 24, letterSpacing: 2),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 20.0,
            velocity: 50,
            startPadding: 0,
            accelerationDuration: Duration(seconds: 10),
            accelerationCurve: Curves.ease,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: TextField(
            autofocus: true,
            onChanged: onType,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Write and catch the text"),
          ),
        ),
      ];
    else
      shownWidget = <Widget>[
        Text("Game Over. Score : $typedCharLength"),
        RaisedButton(
          child: Text("Try Again"),
          onPressed: tryAgain,
        ),
      ];

    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Write Forest Write")),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: shownWidget,
        )));
  }
}
