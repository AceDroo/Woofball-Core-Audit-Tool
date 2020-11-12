import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'survey.dart';

class QuestionTypePage extends StatefulWidget {
  final String address;
  final LatLng latlng;
//  final int page;
//  final bool editMode;

//  QuestionTypePage({Key key, this.address, this.page, this.editMode}) : super(key: key);
  QuestionTypePage({Key key, this.address, this.latlng}) : super(key: key);

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
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height:15),
              Text(
                "Audit Type", 
                style: TextStyle(
                  color: Colors.blue, 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height:15),
              Text("Are you auditing a segment of road or an intersection?"),
              SizedBox(height:15),
            ]
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text("SEGMENT"),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(15),
                  minimumSize: MaterialStateProperty.all<Size>(Size(500,50)),
                  enableFeedback: true,
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Survey(
                        auditType: "Segment", 
                        address: widget.address,
                        latlng: widget.latlng,
                        page: 0,
                        editMode: false
                      )
                    )
                  );
                }
              ),
              SizedBox(height:25),
              ElevatedButton(
                child: Text("INTERSECTION"),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(15),
                  minimumSize: MaterialStateProperty.all<Size>(Size(500,50)),
                  enableFeedback: true,
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Survey(
                        auditType: "Intersection", 
                        address: widget.address,
                        latlng: widget.latlng,
                        page: 0,
                        editMode: false
                      )
                    )
                  );
                }
              )
            ]
          )
        ]
      ),
    );
  }
}
