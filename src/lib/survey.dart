import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'qna.dart';
import 'home.dart';
//import 'results.dart';

class Survey extends StatefulWidget {
  Survey({Key key}) : super(key: key);
  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  static int currentPage = 0;
  int totalPages = 0;
  bool currentUnset = true;
  PageController _pageController;
  List<Widget> pageChildren;
  List<Widget> sectionsChildren;

  PageView questionPage;
  FutureBuilder<List<QuestionCollection>> questions;
  FutureBuilder<List<Section>> sections;

  @override
  void initState() {
    super.initState();
    if (currentUnset) {
      currentPage = 0;
      currentUnset = false;
    }

    // Set up page controller
    _pageController = PageController(initialPage: currentPage);

    // Get survey questions
    if (questions == null) {
      questions = getQuestionPages();
    }

    // Get survey sections
    if (sections == null) {
      sections = getSections();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget getSections() {
    return FutureBuilder<List<Section>>(
        future: Services.loadSections(_pageController),
        builder: (BuildContext context, AsyncSnapshot<List<Section>> snapshot) {
          if (snapshot.hasData) {
            // Successfully loaded in sections
            print("DEBUG: Sections loaded from remote source.");
            sectionsChildren = snapshot.data;
          } else if (snapshot.hasError) {
            // Error occured while loading data
            print("ERROR: ${snapshot.error}");
            sectionsChildren = <Widget>[
              Text("THERE WAS A FATAL ERROR! Unable to obtain question data")
            ];
          } else {
            print("DEBUG: Attempting to obtain sections from remote source...");
            sectionsChildren = <Widget>[
              Text("...")
            ];
          }

          return Drawer(
            child: ListView (
              children: sectionsChildren
            )
          );
        }
    );
  }

  Widget getQuestionPages() {
    return FutureBuilder<List<QuestionCollection>>(
        future: Services.loadQuestion(),
        builder: (BuildContext ctx, AsyncSnapshot<List<QuestionCollection>> snapshot) {
          if (snapshot.hasData) {
            // Successfully loaded questions
            print("DEBUG: Questions loaded from remote source.");
            pageChildren = snapshot.data;
          } else if (snapshot.hasError) {
            // Error occurred while loading data
            print("ERROR: ${snapshot.error}");
            pageChildren = <Widget>[
              Text("THERE WAS A FATAL ERROR! Unable to obtain question data"),
            ];
          } else {
            print("DEBUG: Attempting to obtain questions from remote source...");
            pageChildren = <Widget>[
              Text("..."),
            ];
          }

          // Calculate total pages
          totalPages = pageChildren.length;

          // Return survey pages
          return PageView(
            children: pageChildren,
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
            child: Column(children: <Widget>[
              Text("<<PLACEHOLDER>>"),
              Text("Tap to change location", style: TextStyle(fontSize: 12)),
            ]),
            onTap: () {
              Navigator.pop(context);
            }),
      ),
      body: questions,
      drawer: sections,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'prevFAB',
              onPressed: () {
                _pageController.animateToPage(_pageController.page.toInt() - 1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: Icon(Icons.navigate_before),
            ),
            if (currentPage < totalPages - 1 || currentPage == 0)
              FloatingActionButton(
                heroTag: 'nextFAB',
                onPressed: () {
                  _pageController.animateToPage(
                      _pageController.page.toInt() + 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: Icon(Icons.navigate_next),
              ),
            if (currentPage >= totalPages - 1 && currentPage != 0)
              FloatingActionButton(
                heroTag: 'submitFAB',
                onPressed: () {
                  _pageController.jumpToPage(0);
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                  print("Reached end of survey!");
                },
                child: Icon(Icons.done),
              )
          ],
        ),
      ),
    );
  }
}
