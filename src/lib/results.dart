import 'package:flutter/material.dart';
import 'package:core_audit_tool/home.dart';

import 'survey.dart';
import 'home.dart';
import 'post_audit.dart';

class Results extends StatefulWidget {
  _ResultsState createState() => _ResultsState();
}

Widget text(String text) {
  return Container(
      width: 350,
      child: Text(text,
          style: TextStyle(fontSize: 16), textAlign: TextAlign.left));
}

Widget textLink(String text, BuildContext context) {
  return Container(
      width: 350,
      child: InkWell(
          child: Text(text,
              style: TextStyle(fontSize: 16), textAlign: TextAlign.left),
          onTap: () {
            // Go to previous page
            if (text == "1. Type of Intersection: T-Intersection") {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Survey()), // Go to survey page
              );
            } else if (text == "0. Take or upload photo: No photo uploaded\n") {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Survey()), // Go to survey page
              );
            } else if (text == "4. Number of gathering places: ") {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Survey()), // Go to survey page
              );
            }
          }));
}

class _ResultsState extends State<Results> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: ListView(
      children: <Widget>[
        Center(
            child: Column(
          children: <Widget>[
            Text("\nResults", style: TextStyle(fontSize: 26)),
            Text("A", style: TextStyle(color: Colors.red, fontSize: 48)),
            SizedBox(height: 20),
            ExpansionTile(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text("Summary Report", style: TextStyle(fontSize: 16)),
              children: <Widget>[
                text("Problems: "),
                text(" - Poor footpath quality\n"),
                text("Suggestions:"),
                text(" - Improve footpath quality\n")
              ],
            ),
            SizedBox(height: 10),
            ExpansionTile(
                backgroundColor: Theme.of(context).dialogBackgroundColor,
                title: Text("Detailed Report", style: TextStyle(fontSize: 16)),
                children: <Widget>[
                  ExpansionTile(
                    title: Text("1. Intersection"),
                    children: <Widget>[
                      textLink(
                          "1.1. Type of Intersection: T-Intersection", context),
                      textLink("1.2. Traffic Control: Traffic light", context),
                      textLink(
                          "1.3. Type of Intersection Crosswalk: Zebra striping",
                          context),
                      textLink(
                          "1.4. Crossing Aids at Intersection: None", context),
                      textLink("1.5. Take or upload photo: No photo uploaded\n",
                          context),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).accentTextTheme.button.color,
                            child: new Text("Edit",
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Survey(
                                          page: 0,
                                          editMode: true,
                                        )), // Go to survey page
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("2. Pedestrian Experience"),
                    children: <Widget>[
                      textLink("2.1. Overall cleanliness: 2 (Poor)", context),
                      textLink(
                          "2.2. Features that provide shade: None", context),
                      textLink(
                          "2.3. Articulation in building designs: Little or none\n",
                          context),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).accentTextTheme.button.color,
                            child: new Text("Edit",
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Survey(
                                          page: 1,
                                          editMode: true,
                                        )), // Go to survey page
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("3. Sidewalk"),
                    children: <Widget>[
                      textLink("3.1. Pedestrian facility: None", context),
                      textLink("3.2. Lighting: None\n", context),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).accentTextTheme.button.color,
                            child: new Text("Edit",
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Survey(
                                          page: 2,
                                          editMode: true,
                                        )), // Go to survey page
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("4. Wayfinding"),
                    children: <Widget>[
                      textLink(
                          "4.1. Wayfinding for sidewalk: Landmark\n", context),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).accentTextTheme.button.color,
                            child: new Text("Edit",
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Survey(
                                          page: 3,
                                          editMode: true,
                                        )), // Go to survey page
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("5. Road"),
                    children: <Widget>[
                      textLink("5.1. Number of lanes: 2\n", context),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 10),
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            textColor:
                                Theme.of(context).accentTextTheme.button.color,
                            child: new Text("Edit",
                                style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Survey(
                                          page: 4,
                                          editMode: true,
                                        )), // Go to survey page
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(title: Text("6. Land Uses"), children: <Widget>[
                    textLink("6.1. Uses in segment:", context),
                    text(" - Commercial"),
                    textLink(
                        "6.2. Uses different from those on the first floor? No",
                        context),
                    textLink("6.3. Number of land uses present on the segment:",
                        context),
                    text(" - Bars/Clubs: 1"),
                    text(" - Adult Uses: 0"),
                    text(" - Check cashing/Pawn Shop/Bail Bonds: 1"),
                    textLink("6.4. Number of gathering places: ", context),
                    text(" - Restaurants: 2"),
                    text(" - Coffee Shops: 1"),
                    text(" - Libraries/Bookshops: 1\n"),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: FlatButton(
                          color: Theme.of(context).accentColor,
                          textColor:
                              Theme.of(context).accentTextTheme.button.color,
                          child:
                              new Text("Edit", style: TextStyle(fontSize: 16)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Survey(
                                        page: 5,
                                        editMode: true,
                                      )), // Go to survey page
                            );
                          },
                        ),
                      ),
                    ),
                  ])
                ]),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  color: Theme.of(context).accentColor,
                  textColor: Theme.of(context).accentTextTheme.button.color,
                  child: new Text("Return to Menu",
                      style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Home()), // Go to home page
                    );
                  },
                ),
                FlatButton(
                    color: Theme.of(context).accentColor,
                    textColor: Theme.of(context).accentTextTheme.button.color,
                    child: Text("Submit Audit", style: TextStyle(fontSize: 16)),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                              title: Text("Audit submitted"),
                              content: Text(
                                  "The audit has been successfully submitted."),
                              actions: [
                                new FlatButton(
                                    child: Text("Okay"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Home()), // Go to home page
                                      );
                                    })
                              ],
                            ))),
                FlatButton(
                    color: Theme.of(context).accentColor,
                    textColor: Theme.of(context).accentTextTheme.button.color,
                    child: Text("Perform Post Audit", style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UnityDemoScreen()), // Go to home page
                      );
                    })
              ],
            ),
          ],
        ))
      ],
    )));
  }
}
