import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'qna.dart';
//import 'results.dart';

class Survey extends StatefulWidget {
  Survey({Key key}) : super(key: key);

  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  PageController _pageController;
  
  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          child: Column(
            children: <Widget>[
              Text("<<PLACEHOLDER>>"),
              Text(
                "Tap to change location",
                style: TextStyle(fontSize: 12)),
            ]
          ),
          onTap: () {
            Navigator.pop(context);
          }
        ),
      ),
      body: FutureBuilder<List<QuestionCollection>>(
        future: Services.loadQuestion(),
        builder: (BuildContext ctx, AsyncSnapshot<List<QuestionCollection>> snapshot){
          List<Widget> children;
          if(snapshot.hasData){
            print("DEBUG: Questions loaded from remote source.");
            children = snapshot.data;
          }else if(snapshot.hasError){
            print("ERROR: ${snapshot.error}");
            children = <Widget>[
              Text("THERE WAS A FATAL ERROR! Unable to obtain question data"),
            ]; 
          }else{
            print("DEBUG: Attempting to obtain questions from remote source...");
            children = <Widget>[
              Text("..."),
            ];
          }
          return PageView(
              children: children,
          );
        }
      ),
    );
  }
}
