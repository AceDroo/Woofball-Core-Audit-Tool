import 'package:core_audit_tool/qna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Results extends StatefulWidget {
  Results(this._addr, {Key key}) : super(key: key);

  final String _addr;
  final String _grade = "B";
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Widget getDetailedReport() {
    List<Widget> reportData;

    return FutureBuilder(
      future: Services.loadDetailedReport(widget._addr),
        builder: (BuildContext context, AsyncSnapshot<List<DetailedReportSection>> snapshot) {
          if (snapshot.hasData) {
            // Successfully loaded detailed report
            print("Successfully loaded Detailed Report");
            reportData = snapshot.data;
          } else if (snapshot.hasError) {
            // Error occurred while loading data
            print("ERROR: ${snapshot.error}");
            reportData = <Widget>[
              Text("THERE WAS A FATAL ERROR! Unable to obtain question data")
            ];
          } else {
            print("DEBUG: Attempting to obtain questions from remote source...");
            reportData = <Widget>[
              Text("..."),
            ];
          }
          return Column(
            children: reportData,
          );
        }
    );
  }

  Widget build(BuildContext context) {
    double _width = 320.0;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: InkWell(
              child: Column(children: <Widget>[
                Text(widget._addr),
                Text("Tap to change location", style: TextStyle(fontSize: 12)),
              ]),
              onTap: () {
                Navigator.pop(context);
              }),
        ),
        body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          DefaultTextStyle(
              style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
              textAlign: TextAlign.center,
              textWidthBasis: TextWidthBasis.parent,
              child: Center (
                widthFactor: 100,
                child: Column (
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text("Results", style: TextStyle(color: Theme.of(context).accentColor, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(widget._grade, style: TextStyle(color: Colors.red, fontSize: 48)),
                    SizedBox(height: 20),
                    ExpansionTile(
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      title: Text("Summary Report", style: TextStyle(fontSize: 16)),
                      children: [
                        Container(
                          width: _width,
                          child: Text(
                            "PLACEHOLDER VERDICT.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: _width,
                          child: Text("\nSuggested problems and solutions: ",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: _width,
                          child: Text(" - PLACEHOLDER ISSUE + SOLUTION",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    ExpansionTile(
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      title: Text("Detailed Report", style: TextStyle(fontSize: 16)),
                      children: <Widget>[
                        getDetailedReport()
                      ]
                      ,
                    ),
                    ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          textColor: Theme.of(context).accentTextTheme.button.color,
                          child: Text("Return to Menu", style: TextStyle(fontSize: 16)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                          },
                        ),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          textColor: Theme.of(context).accentTextTheme.button.color,
                          child: Text("Submit Audit", style: TextStyle(fontSize: 16)),
                          onPressed: () async {
                            final ConfirmAction action = await confirmAudit(context);
                            if (action == ConfirmAction.Yes) {
                              submitAudit(context);
                            }
                          }
                        )
                      ],
                    )
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}

enum ConfirmAction { No, Yes }
Future<ConfirmAction> confirmAudit(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Submit Audit"),
        content: Text("Submit the completed audit?"),
        actions: [
          FlatButton(
            color: Theme.of(context).accentColor,
            textColor: Theme.of(context).accentTextTheme.button.color,
            child: Text("No"),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.No);
            },
          ),
          FlatButton(
            color: Theme.of(context).accentColor,
            textColor: Theme.of(context).accentTextTheme.button.color,
            child: Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.Yes);
            },
          )
        ],
      );
    }
  );
}

void submitAudit(BuildContext context) {
  print("Submitting audit...");
  print("Audit submitted!");

  // Show submission dialogue
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Audit Submitted"),
          content: Text("Audit has been successfully submitted"),
          actions: [
            FlatButton(
              color: Theme.of(context).accentColor,
              textColor: Theme.of(context).accentTextTheme.button.color,
              child: Text("Confirm"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
              },
            )
          ],
        );
      }
  );
}
