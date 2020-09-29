import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'survey.dart';

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

    for (var data in questionData.entries) {
      List<StatefulWidget> contents = List<StatefulWidget>();

      // Get title and total elements found
      title = data.key.toString();
      int length = data.value.length;

      // Add section title
      Title sectionTitle = Title(title: title);
      contents.add(sectionTitle);

      for (int i = 0; i < length; i++) {
        // Get question and its type
        question = data.value[i]['question'].toString();
        type = data.value[i]['options']['type'].toString();

        if (type == "slider") {
          min = data.value[i]['options']['min'];
          max = data.value[i]['options']['max'];

          SliderQuestion slider = SliderQuestion(min: min, max: max, text: question);
          contents.add(slider);
        } else {
          CheckboxQuestion checkbox = CheckboxQuestion(text: question);
          contents.add(checkbox);
        }
      }

      // Add spacer at the end of the question page
      SurveyPageSpacer spacer = SurveyPageSpacer();
      contents.add(spacer);

      // Create collection and it to contents
      QuestionCollection collection = QuestionCollection(title: title, contents: contents);
      collections.add(collection);
    }

    return collections;
  }
  static Future<List<Section>> loadSections(PageController _controller) async {
    List<Section> sections = List<Section>();
    String title;

    String jsonString = await _loadAQuestionAsset();
    final questionData = json.decode(jsonString);

    sections.add(new Section(title: "Header"));

    int i = 0;
    for (var data in questionData.entries) {
      // Get title
      title = data.key.toString();

      // Create section and add it to list
      Section section = Section(title: title, page: i);
      section.setController(_controller);
      sections.add(section);

      i++;
    }

    return sections;
  }
  static Future<List<DetailedReportSection>> loadDetailedReport(String _address) async {
    List<DetailedReportSection> sections = List<DetailedReportSection>();
    String title;
    String question;

    String jsonString = await _loadAQuestionAsset();
    final questionData = json.decode(jsonString);

    int sectionNum = 1;
    for (var data in questionData.entries) {
      List<StatefulWidget> contents = List<StatefulWidget>();

      // Get title and total elements found
      title = data.key.toString();
      int length = data.value.length;

      print(sectionNum.toString() + ". " + title);

      for (int i = 0; i < length; i++) {
        // Get question and its type
        question = data.value[i]['question'].toString();

        TextLink link = new TextLink(section: sectionNum, questionNumber: i + 1, questionText: question, result: 1, address: _address);

        contents.add(link);

        print(sectionNum.toString() + "." + i.toString() + ". " + question);
      }

      // Increment section number
      sectionNum++;

      // Create collection and it to contents
      DetailedReportSection section = DetailedReportSection(title: title, contents: contents);
      sections.add(section);
    }

    return sections;
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
    ListView view = ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
            textWidthBasis: TextWidthBasis.parent,
            child: Center(
              widthFactor: 100,
              child: Column(
                children: widget.contents,
              ),
            ))
      ],
    );
    return view;
  }
}

// Title
class Title extends StatefulWidget {
  final String title;

  Title({Key key, this.title}) : super(key: key);

  @override
  _TitleState createState() => _TitleState();
}

class _TitleState extends State<Title> {
  @override
  Widget build(BuildContext ctx) {
    return Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text("\n" + widget.title + " ", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
              InkWell(
                  child: new Text("?", style: TextStyle(color: Colors.blue, fontSize: 18, decoration: TextDecoration.underline)),
                  onTap: () {
                    showDialog(context: ctx,
                        builder: (ctx) => new AlertDialog(
                          title: Text(widget.title),
                          content: Text("Hello There!"),
                        )
                    );
                  })
            ])
    );
  }
}

// Survey Page Spacer
class SurveyPageSpacer extends StatefulWidget {
  SurveyPageSpacer();

  @override
  _SurveyPageSpacer createState() => _SurveyPageSpacer();
}
class _SurveyPageSpacer extends State<SurveyPageSpacer> {
  @override
  Widget build(BuildContext ctx) {
    return SizedBox(height: 64);
  }
}

// Section
// ignore: must_be_immutable
class Section extends StatefulWidget {
  final String title;
  final int page;
  PageController controller;

  Section({Key key, this.title, this.page}) : super(key : key);

  void setController(PageController controller) {
    this.controller = controller;
  }

  @override
  _SectionState createState() => _SectionState();
}

class _SectionState extends State<Section> {
  @override
  Widget build(BuildContext context) {
    if (widget.title == "Header") {
      return Center(
        heightFactor: 2,
        child: Text (
          "Sections", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold))
      );
    }
    return ListTile(
        title: Text(widget.title),
        onTap: () {
          print(widget.page);
          if (widget.controller != null) {
            widget.controller.jumpToPage(widget.page);
            Navigator.pop(context);
          }
        }
    );
  }
}

// Question
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
    return Container(child: Text(widget.text));
  }
}

// Slider Question
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
    return Column(children: <Widget>[
      Question(text: widget.text),
      Slider(
        value: _sliderVal,
        min: widget.min.toDouble(),
        max: widget.max.toDouble(),
        divisions: widget.max,
        label: _hintLabel,
        onChanged: (value) {
          setState(() {
            switch (value.toInt()) {
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
    ]);
  }
}

// Checkbox Question
class CheckboxQuestion extends StatefulWidget {
  final String text;

  CheckboxQuestion({Key key, this.text}) : super(key: key);

  @override
  _CheckboxQuestionState createState() => _CheckboxQuestionState();
}
class _CheckboxQuestionState extends State<CheckboxQuestion> {
  bool yesVal = false;
  @override
  Widget build(BuildContext ctx) {
    return Column(children: <Widget>[
      CheckboxListTile(
        title: Text(widget.text),
        value: yesVal,
        onChanged: (bool value) {
          setState(() {
            yesVal = value;
          });
        },
      ),
    ]);
  }
}

class DetailedReportSection extends StatefulWidget {
  final String title;
  final List<StatefulWidget> contents;

  DetailedReportSection({Key key, this.title, this.contents}) : super(key: key);

  @override
  _DetailedReportSectionState createState() => _DetailedReportSectionState();
}

class _DetailedReportSectionState extends State<DetailedReportSection> {
  @override
  Widget build(BuildContext ctx) {
    return ExpansionTile(
        title: Text(widget.title),
        children: widget.contents
    );
  }
}


class TextLink extends StatefulWidget {
  final int section;
  final int questionNumber;
  final String questionText;
  final int result;
  final String address;

  TextLink({Key key, this.section, this.questionNumber, this.questionText, this.result, this.address}) : super(key : key);

  @override
  _TextLinkState createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> {
  @override
  Widget build(BuildContext context) {
    // Build text string
    String sectionNum = widget.section.toString() + " " + widget.questionNumber.toString() + ". ";
    String sectionInfo = widget.questionText + " - " + widget.result.toString() + "\n";

    // Return container
    return Container(
      width: 350,
      child: InkWell(
        child: Text(sectionNum + sectionInfo, style: TextStyle(fontSize: 16), textAlign: TextAlign.left),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Survey(address: widget.address, page: widget.section, editMode: true)) // Go to survey page
          );
        }
      ),
    );
  }
}