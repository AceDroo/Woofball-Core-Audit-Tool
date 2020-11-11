import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'qna.dart';
import 'results.dart';

class Survey extends StatefulWidget {
  final String auditType;
  final String address;
  final LatLng latlng;
  final int page;
  final DataHandler handler = DataHandler();
  final bool editMode;

  Survey({Key key, this.auditType, this.address, this.latlng, this.page, this.editMode}) : super(key: key);

  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  static int currentPage = 0;
  int totalPages = 0;
  bool currentUnset = true;
  PageController _pageController;

  List<Widget> pages;
  List<Widget> sections = List<Widget>();
  FutureBuilder<List<QuestionCollection>> questions;

  @override
  void initState() {
    super.initState();
    if (currentUnset) {
      currentPage = widget.page;
      currentUnset = false;
    }

    // Set up page controller
    _pageController = PageController(initialPage: currentPage);

    // Get survey questions
    if (questions == null) {
      questions = loadSurvey();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget loadSurvey() {
    return FutureBuilder<List<QuestionCollection>>(
        future: widget.handler.buildSurvey(widget.auditType, widget.latlng),
        builder: (BuildContext ctx, AsyncSnapshot<List<QuestionCollection>> snapshot) {
          if (snapshot.hasData) {
            print("Questions loaded from remote source.");
            pages = snapshot.data;
            int n = 0;
            sections.add(Container(
                margin: EdgeInsets.all(15),
                child: Text(
                  "Jump to Category...", 
                  style: TextStyle(
                    color: Colors.blue, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  )
                )
              )
            );
            for (QuestionCollection page in pages){
              sections.add(Section(title: page.title, page: n++, controller: _pageController));
            }
          } else if (snapshot.hasError) {
            // Error occurred while loading data
            print("Questions couldn't be fetched:\n ${snapshot.error}");
            pages = <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 50.0,
                        semanticLabel: "Connection error."
                    ),
                    SizedBox(height:15),
                    Text(
                        "We failed to fetch the audit questions at this time, please try to create a new audit.",
                        textAlign: TextAlign.center)
                  ]
              )
            ];
          } else {
            print("Attempting to obtain questions from remote source...");
            pages = <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height:15),
                  Text("Fetching audit questions...")
                ]
              )
            ];
          }

          // Calculate total pages
          totalPages = pages.length;

          // Return survey pages
          return PageView(
            children: pages,
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
              Text(widget.address),
              Text("Tap to change location", style: TextStyle(fontSize: 12)),
            ]),
            onTap: () {
              Navigator.pop(context);
            }),
      ),
      body: questions,
      drawer: Drawer(
          child: ListView(
              children: sections
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (currentPage > 0)
              FloatingActionButton(
                heroTag: 'prevFAB',
                onPressed: () {
                  _pageController.animateToPage(_pageController.page.toInt() - 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: Icon(Icons.navigate_before),
              ),
            if (currentPage == 0)
              SizedBox(width:10),
            if ((currentPage < totalPages - 1 || currentPage == 0) && (!widget.editMode))
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
            if ((currentPage >= totalPages - 1 && currentPage != 0) || (widget.editMode))
              FloatingActionButton(
                heroTag: 'submitFAB',
                onPressed: () {
                  _pageController.jumpToPage(0);
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Results(widget.auditType, widget.address)));
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
