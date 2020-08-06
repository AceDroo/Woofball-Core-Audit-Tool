import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(String) callback;
  
  SearchBar({Key key, this.title, this.hintText, this.callback}) : super(key: key);
  
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  
  final _textController = TextEditingController();
  
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    widget.callback(value);
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      margin: EdgeInsets.only(left:10, right:10, top:45),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
            offset: new Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              // probably display history or something
            },
            icon: Icon(Icons.search),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
              ),
              onSubmitted: _handleSubmitted,
              controller: _textController,
            ),
          ),
        ],
      ),
    );
  }
}
