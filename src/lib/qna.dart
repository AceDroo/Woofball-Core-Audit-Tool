import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'survey.dart';

enum LocationType {
  INTERSECTION,
  SEGMENT
}

class Services {
  static String filename = "assets/questions.json";

  static Future<String> _fetchAQuestion(String auditType) async{
    final String apiUrl = "https://z5vplyleb9.execute-api.ap-southeast-2.amazonaws.com/release/getQuestions";
    final String apiToken = "2T8hefWnH0XikA3yJLYAkQ";

    final response = await http.post(apiUrl, body: json.encode({
      "token": apiToken,
      "auditType": auditType
    }));
    debugPrint(response.toString());
    if (200 == response.statusCode) {
      debugPrint("Questions successfully loaded.");
    }
    return response.body.toString();
  }


  static Future<List<QuestionCollection>> loadQuestion() async {
    // Initialise Variables
    List<QuestionCollection> collections = List<QuestionCollection>();
    String title;
    String question;
    String type;

    // Add intersection/segment question
    List<StatefulWidget> locationSection = List<StatefulWidget>();
    Title locationTitle = Title(title: "Location Type");
    RadioQuestion locationQuestion = RadioQuestion(text: "Is the audited location a road segment or an intersection?", options: ["Segment", "Intersection"], multipleAnswers: false);
    locationSection.add(locationTitle);
    locationSection.add(locationQuestion);
    QuestionCollection collection = QuestionCollection(title: "Location Type", contents: locationSection);
    collections.add(collection);

    // Load in JSON data
    String test = "Intersection";

    String jsonString = await _fetchAQuestion(test);
    final responseData = json.decode(jsonString);
    final questionData = responseData["body"]["questionsList"];

    // Create sections with questions
    for (var data in questionData) {
      // Create contents
      List<StatefulWidget> contents = List<StatefulWidget>();

      // Get title, questions and question length
      title = data["category"];
      var questions = data["questions"];
      int length = questions.length;

      // Add section title
      Title sectionTitle = Title(title: title);
      contents.add(sectionTitle);

      // Create sections
      for (int i = 0; i < length; i++) {
        // Get question and its type
        question = questions[i]['question'].toString();
        type = questions[i]['parameters']['type'].toString();

        switch (type) {
          case "slider": {
              List options = questions[i]['parameters']['options'];
              SliderQuestion slider = SliderQuestion(text: question, contents: options);
              contents.add(slider);
            }
            break;
            case "checkbox": {
              CheckboxQuestion checkbox = CheckboxQuestion(text: question);
              contents.add(checkbox);
            }
            break;
            case "radio": {
              List options = questions[i]['parameters']['options'];
              bool multipleAnswers = (questions[i]['parameters']['multiple_answers'].toLowerCase() == "true");

              RadioQuestion radio = RadioQuestion(options: options, multipleAnswers: multipleAnswers, text: question);
              contents.add(radio);
            }
            break;
            case "dropdown": {
              List options = questions[i]['parameters']['options'];
              DropDownQuestion dropdown = DropDownQuestion(title: question, options: options);
              contents.add(dropdown);
            }
            break;
            default:
              debugPrint("Error: No question of type " + type + " is currently implemented!");
            break;
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
    // Initialise section variables
    List<Section> sections = List<Section>();
    String title;

    // Load in JSON data
    String jsonString = await  _fetchAQuestion("Intersection");
    final responseData = json.decode(jsonString);
    final questionData = responseData["body"]["questionsList"];

    // Add Sections Header
    sections.add(new Section(title: "Header"));

    // Add Location Section
    Section locationSection = new Section(title: "Location Type", page: 0);
    locationSection.setController(_controller);
    sections.add(locationSection);

    int i = 1;
    for (var data in questionData) {
      // Get title
      title = data["category"];

      // Create section and add it to list
      Section section = Section(title: title, page: i);
      section.setController(_controller);
      sections.add(section);

      i++;
    }

    return sections;
  }
  static Future<List<DetailedReportSection>> loadDetailedReport(String _address) async {
    // Initialise variables
    List<DetailedReportSection> sections = List<DetailedReportSection>();
    String title;
    String question;
    int sectionNum = 0;

    // Load in JSON data
    String jsonString = await _fetchAQuestion("Intersection");
    final responseData = json.decode(jsonString);
    final questionData = responseData["body"]["questionsList"];

    // Add Location Text Link
    List<StatefulWidget> locationContents = List<StatefulWidget>();
    TextLink locationLink = new TextLink(section: sectionNum++, questionNumber: 1, questionText: "Is the audited location an intersection or a road segment?", result: 0, address: _address);
    locationContents.add(locationLink);
    DetailedReportSection locationSection = DetailedReportSection(title: "Location Type", contents: locationContents);
    sections.add(locationSection);

    // Load in detailed report
    for (var data in questionData) {
      List<StatefulWidget> contents = List<StatefulWidget>();

      // Get title and total elements found
      title = data["category"];
      var questions = data["questions"];
      int length = questions.length;

      for (int i = 0; i < length; i++) {
        // Get question and its type
        question = questions[i]['question'].toString();

        // Create Text Link and add to contents
        TextLink link = new TextLink(section: sectionNum, questionNumber: i + 1, questionText: question, result: 1, address: _address);
        contents.add(link);
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
  final String text;
  final List contents;

  SliderQuestion({Key key, this.text, this.contents}) : super(key: key);

  @override
  _SliderQuestionState createState() => _SliderQuestionState();
}
class _SliderQuestionState extends State<SliderQuestion> {
  double _sliderVal = 0;
  String _hintLabel;

  @override
  Widget build(BuildContext ctx) {
    return Column(children: <Widget>[
      Question(text: widget.text),
      Slider(
        value: _sliderVal,
        min: 0,
        max: (widget.contents.length - 1).toDouble(),
        divisions: widget.contents.length - 1,
        label: _hintLabel,
        onChanged: (value) {
          setState(() {
            print("NEW VAL: $value");
            _sliderVal = value;
            _hintLabel = widget.contents[value.toInt()];
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

// Radio Question
class RadioQuestion extends StatefulWidget {
  final String text;
  final List options;
  final bool multipleAnswers;

  RadioQuestion({Key key, this.text, this.options, this.multipleAnswers}) : super(key: key);

  @override
  _RadioQuestionState createState() => _RadioQuestionState();
}
class _RadioQuestionState extends State<RadioQuestion> {
  String _selected;

  @override
  Widget build(BuildContext ctx) {
    List<Widget> widgetsList = [];

    // Add question widget
    widgetsList.add(Question(text: widget.text));

    // Create Radio Button Options
    for (String option in widget.options) {
      RadioListTile<String> tile = RadioListTile<String>(
        title: Text(option),
        value: option,
        groupValue: _selected,
        onChanged: (String value) {
          setState(() {
            print("NEW VAL: " + value);
            _selected = value;
          });
        },
      );

      widgetsList.add(tile);
    }

    return Column(
        children: widgetsList
    );
  }

  String getSelected() {
    return _selected;
  }
}

class DropDownQuestion extends StatefulWidget {
  final String title;
  final List options;

  DropDownQuestion({Key key, this.title, this.options}) : super(key: key);

  @override
  _DropDownQuestionState createState() => _DropDownQuestionState();
}

class _DropDownQuestionState extends State<DropDownQuestion> {
  String _value;

  @override
  Widget build(BuildContext context) {
    // Create list options
    List<Widget> widgetsList = [];
    List<DropdownMenuItem<String>> optionsList = [];

    // Add Title to list
    widgetsList.add(Text(widget.title));

    // Create drop down list options
    for (String option in widget.options) {
      DropdownMenuItem<String> item = DropdownMenuItem<String>(
        child: Text(option),
        value: option,
      );

      optionsList.add(item);
    }

    // Create Drop Down Button
    DropdownButton button = new DropdownButton(
        hint: Text("Select Item"),
        value: _value,
        items: optionsList,
        onChanged: (value) {
          setState(() {
            _value = value;
          });
        }
    );
    widgetsList.add(button);

    return Column(
      children: widgetsList
    );
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
