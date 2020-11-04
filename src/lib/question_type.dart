import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'survey.dart';

class QuestionTypePage extends StatefulWidget {
  final String address;
//  final int page;
//  final bool editMode;

//  QuestionTypePage({Key key, this.address, this.page, this.editMode}) : super(key: key);
  QuestionTypePage({Key key, this.address}) : super(key: key);

  _QuestionTypePageState createState() => _QuestionTypePageState();
}

class _QuestionTypePageState extends State<QuestionTypePage> {
  String _selected = "";

  @override
  Widget build(BuildContext context) {
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
        //RadioQuestion locationQuestion = RadioQuestion(text: "Is the audited location a road segment or an intersection?", options: ["Segment", "Intersection"], multipleAnswers: false);
      body: ListView (
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("\nAudit Type", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Is the audited location a segment or an intersection?")
            ],
          ),
          RadioListTile(
            title: Text("Segment"),
            value: "Segment",
            groupValue: _selected,
            onChanged: (String value) {
              setState(() {
                _selected = value;
              });
            }
          ),
          RadioListTile(
            title: Text("Intersection"),
            value: "Intersection",
            groupValue: _selected,
            onChanged: (String value) {
              setState(() {
                _selected = value;
              });
            }
          )
            ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                heroTag: 'nextFAB',
                onPressed: () {
                  Navigator.pop(context); // Closes drawer
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => Survey(auditType: _selected, address: widget.address, page: 0, editMode: false), // Go to initial survey page
                  ));
                },
                child: Icon(Icons.navigate_next),
              ),
          ],
        ),
      ),
    );
  }
}