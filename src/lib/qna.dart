import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Services {
  static Future<String> _loadAQuestionAsset() async {
    return await rootBundle.loadString('assets/questions.json');
  }


  static Future<List<QuestionCollection>> loadQuestion() async {
    List<QuestionCollection> collections = List<QuestionCollection>();
    String title;
    String question;
    String type;
    int min;
    int max;

    String jsonString = await _loadAQuestionAsset();
    final questionData = json.decode(jsonString);

    for(var data in questionData.entries) {

      List<StatefulWidget> contents = List<StatefulWidget>();

      title = data.key.toString();
      int length = data.value.length;

      for(int i = 0 ; i < length; i++){
        question = data.value[i]['question'].toString();
        type = data.value[i]['options']['type'].toString();

        debugPrint(question);
        if(type == "slider"){
          min = data.value[i]['options']['min'];
          max = data.value[i]['options']['max'];

          SliderQuestion slider = SliderQuestion(min: min, max: max, text: question);
          contents.add(slider);

        }else{
          CheckboxQuestion checkbox = CheckboxQuestion(text: question);
          contents.add(checkbox);
        }
      }
      QuestionCollection collection = QuestionCollection(title: title, contents: contents);
      collections.add(collection);
    }

    return collections;
  }
}

class QuestionCollection extends StatefulWidget {
  final String title;
  final List<StatefulWidget> contents;
  
  QuestionCollection({Key key, this.title, this.contents}) : super(key: key);

  @override
  _QuestionCollectionState createState() => _QuestionCollectionState();

}

class _QuestionCollectionState extends State<QuestionCollection> {
  @override
  Widget build(BuildContext ctx) {
    return ListView(children: widget.contents); 
  }
}

class Question extends StatefulWidget {
  final String text;
 // final double weight;

  Question({Key key, this.text}) : super(key: key);

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext ctx) {
    return Container(
      child: Text(widget.text)
    );
  }
}

class SliderQuestion extends StatefulWidget {
  final int min;
  final int max;
  final String text;

  SliderQuestion({Key key, this.min, this.max, this.text}) : super(key: key);

  @override
  _SliderQuestionState createState() => _SliderQuestionState();

}

class _SliderQuestionState extends State<SliderQuestion> {
  double _sliderVal = 0;
  String _hintLabel = "Not at all";
  
  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: <Widget>[
        Question(text: widget.text),
        Slider(
          value: _sliderVal,
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: widget.max,
          label: _hintLabel,
          onChanged: (value){
            setState(() {
              switch(value.toInt()) {
                case 0:
                  print("NEW VAL: $value");
                  _sliderVal = value;
                  _hintLabel = "Not at all";
                  break;
                case 1:
                  print("NEW VAL: $value");
                  _sliderVal = value;
                  _hintLabel = "Rarely";
                  break;
                case 2:
                  print("NEW VAL: $value");
                  _sliderVal = value;
                  _hintLabel = "Occasionally";
                  break;
                case 3:
                  print("NEW VAL: $value");
                  _sliderVal = value;
                  _hintLabel = "Frequently";
                  break;
                case 4:
                  print("NEW VAL: $value");
                  _sliderVal = value;
                  _hintLabel = "Very Frequently";
                  break;
              }
            });
          },
        )
      ]
    );
  }
}

class CheckboxQuestion extends StatefulWidget{
  final String text;

  CheckboxQuestion({Key key,this.text}) : super(key: key);

  @override
  _CheckboxQuestionState createState() => _CheckboxQuestionState();

}

class _CheckboxQuestionState extends State<CheckboxQuestion>{
  bool yesVal = false;
  @override
  Widget build(BuildContext ctx) {
    return Column(
        children: <Widget>[
          Question(text: widget.text),
          Checkbox(
            value: yesVal,
            onChanged: (bool value) {
              setState(() {
                yesVal = value;
              });
            }
          )
        ]
    );
  }
}
