import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class PostAudit extends StatefulWidget {
  PostAudit({Key key}) : super(key: key);

  _PostAuditState createState() => _PostAuditState();
}

class _PostAuditState extends State<PostAudit> {
  //static final GlobalKey<ScaffoldState> _scaffoldKey  GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //key: _scaffoldKey,
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () {
            // Pop the category page if Android button is pressed.
            
          },
          child: Container(
            color: Colors.yellow,
          )
        ),
      ),
    );
  }
}