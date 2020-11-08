import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'survey.dart';

class DataHandler {
  final Map<String, dynamic> _output = {};
  List<QuestionCollection> survey = List<QuestionCollection>();
  
  // JG: API url and token
  final String _apiURL = "https://z5vplyleb9.execute-api.ap-southeast-2.amazonaws.com/release/getQuestions";
  final String _apiToken = "2T8hefWnH0XikA3yJLYAkQ";

  Future<String> _fetchQuestions(String auditType) async {
    var response = await http.post(_apiURL, body: json.encode({
      "token": _apiToken,
      "auditType": auditType
    }));

    if (200 != response.statusCode) {
      throw("Unable to gather Questions from remote source: $_apiURL");
    }
    debugPrint("Received status code 200 from remote source: $_apiURL");
    return response.body.toString();
  }

  // JG: Using the received json, we can build a survey
  // out of our various question widgets defined in this library
  Future<List<QuestionCollection>> buildSurvey(String auditType) async {
    List<QuestionCollection> survey = <QuestionCollection>[];
    String auditJson = await _fetchQuestions(auditType); 

    // JG: building the questions and adding them to collections
    List sections = json.decode(auditJson)["body"]["questionsList"];
    for (var section in sections) {
      List<dynamic> questions = section["questions"];
      List<StatefulWidget> collectionContents = <StatefulWidget>[];
      for (var question in questions) {
        String id = question["id"];
        String text = question["question"];
        List<dynamic> options = question["parameters"]["options"];
        print(options);
        double weight = double.parse(question["weighting"]); 
        switch(question["parameters"]["type"]) {
          case "slider": {
            collectionContents.add(SliderQuestion(
                                    id: question["id"],
                                    text: question["question"],
                                    options: question["parameters"]["options"],
                                    weight: double.parse(question["weighting"]),
                                    callback: updateOutput
            ));
          }
          break;
          case "checkbox": {
            collectionContents.add(CheckboxQuestion(
                                    id: question["id"],
                                    text: question["question"],
                                    weight: double.parse(question["weighting"]),
                                    callback: updateOutput
            ));
          }
          break;
          case "radio": {
            collectionContents.add(RadioQuestion(
                                    id: question["id"],
                                    text: question["question"],
                                    weight: double.parse(question["weighting"]),
                                    multipleAnswers: question["parameters"]["mutliple_answers"].toLowerCase(),
                                    callback: updateOutput
            ));
          }
          break;
          case "dropdown": {
            collectionContents.add(DropdownQuestion(
                                    id: question["id"],
                                    text: question["question"],
                                    weight: double.parse(question["weighting"]),
                                    callback: updateOutput
            ));
          }
          break;
          default: {
            print("No widget exists for ${question["parameters"]["type"]}");
          }
        }
      }
      collectionContents.add(new SurveyPageSpacer());
      survey.add(QuestionCollection(title: section["category"], contents: collectionContents));
    }
    return survey;
  }

  void updateOutput(String key, dynamic value) {
    _output[key] = value;
  }
}

class Services {
  static String auditJson;
  // JG: where we store the map that will get sent to the API
  static Map<String, dynamic> outputData = {};

  // JG: handy callback for our methods to use for updating the
  // outputData map
  static void updateData(String key, dynamic val) {
    outputData[key] = val;
  }

  static Future<String> _fetchAQuestion(String auditType) async {
    final String apiUrl = "https://z5vplyleb9.execute-api.ap-southeast-2.amazonaws.com/release/getQuestions";
    final String apiToken = "2T8hefWnH0XikA3yJLYAkQ";

    // JG: first important part of the audit data
    // JG: we clear the map first, so we don't get any lingering values
    outputData.clear();
    outputData["auditType"] = auditType;
    
    final response = await http.post(apiUrl, body: json.encode({
      "token": apiToken,
      "auditType": auditType
    }));

    if (200 == response.statusCode) {
      debugPrint("Questions successfully loaded.");
    }
    return response.body.toString();
  }


  static Future<List<QuestionCollection>> loadQuestion(String auditType) async {
    // Initialise Variables
    List<QuestionCollection> collections = List<QuestionCollection>();
    String id;
    String title;
    String question;
    String type;
    double weight;

    // Load in JSON data
    if (auditJson == null) {
      auditJson = await _fetchAQuestion(auditType);
    }

    final responseData = json.decode(auditJson);
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
      QuestionTitle sectionQuestionTitle = QuestionTitle(title: title);
      contents.add(sectionQuestionTitle);

      // Create sections
      for (int i = 0; i < length; i++) {
        // Get question and its types, as well as weights and id
        id = questions[i]['id'].toString();
        question = questions[i]['question'].toString();
        type = questions[i]['parameters']['type'].toString();
        weight = double.parse(questions[i]['weighting']);
        switch (type) {
          case "slider": {
              List options = questions[i]['parameters']['options'];
              SliderQuestion slider = SliderQuestion(id: id, text: question, options: options, weight: weight, callback: updateData);
              contents.add(slider);
            }
            break;
            case "checkbox": {
              CheckboxQuestion checkbox = CheckboxQuestion(id: id, text: question, weight: weight, callback: updateData);
              contents.add(checkbox);
            }
            break;
            case "radio": {
              List options = questions[i]['parameters']['options'];
              bool multipleAnswers = (questions[i]['parameters']['multiple_answers'].toLowerCase() == "true");

              RadioQuestion radio = RadioQuestion(id: id, options: options, multipleAnswers: multipleAnswers, text: question, weight: weight, callback: updateData);
              contents.add(radio);
            }
            break;
            case "dropdown": {
              List options = questions[i]['parameters']['options'];
              DropdownQuestion dropdown = DropdownQuestion(id: id, text: question, options: options, weight: weight, callback: updateData);
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

  static Future<List<Section>> loadSections(String auditType, PageController _controller) async {
    // Initialise section variables
    List<Section> sections = List<Section>();
    String title;

    // Load in JSON data
    if (auditJson == null) {
      auditJson = await  _fetchAQuestion(auditType);
    }

    final responseData = json.decode(auditJson);
    final questionData = responseData["body"]["questionsList"];

    // Add Sections Header
    sections.add(new Section(title: "Header"));

    int i = 0;
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
  static Future<List<DetailedReportSection>> loadDetailedReport(String auditType, String _address) async {
    // Initialise variables
    List<DetailedReportSection> sections = List<DetailedReportSection>();
    String title;
    String question;
    int sectionNum = 0;

    // Load in JSON data
    if (auditJson == null) {
      auditJson = await _fetchAQuestion(auditType);
    }

    final responseData = json.decode(auditJson);
    final questionData = responseData["body"]["questionsList"];

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
  final Map<String, dynamic> data = {};
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

// QuestionTitle
class QuestionTitle extends StatefulWidget {
  final String title;

  QuestionTitle({Key key, this.title}) : super(key: key);

  @override
  _QuestionTitleState createState() => _QuestionTitleState();
}

class _QuestionTitleState extends State<QuestionTitle> {
  @override
  Widget build(BuildContext ctx) {
    return Container(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text("\n" + widget.title + " ", style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
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
  String id;
  String text;
  List options;
  double weight;
  void Function(String id, dynamic data) callback;

  SliderQuestion({Key key, this.id, this.text, this.options, this.weight, this.callback}) : super(key: key);

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
        max: (widget.options.length - 1).toDouble(),
        divisions: widget.options.length -1,
        label: _hintLabel,
        onChanged: (value) {
          setState(() {
            print("NEW VAL: $value");
            _sliderVal = value;
            _hintLabel = widget.options[value.toInt()];
            widget.callback(widget.id, value);
          });
        },
      )
    ]);
  }
}

// Checkbox Question
class CheckboxQuestion extends StatefulWidget {
  final String id;
  final String text;
  final double weight;
  final void Function(String id, dynamic data) callback;

  CheckboxQuestion({Key key, this.id , this.text, this.weight, this.callback}) : super(key: key);

  @override
  _CheckboxQuestionState createState() => _CheckboxQuestionState();
}
class _CheckboxQuestionState extends State<CheckboxQuestion> {
  bool _yesVal = false;
  
  String getData() {
    return _yesVal.toString();
  }
  
  @override
  Widget build(BuildContext ctx) {
    return Column(children: <Widget>[
      CheckboxListTile(
        title: Text(widget.text),
        value: _yesVal,
        onChanged: (bool value) {
          setState(() {
            _yesVal = value;
            widget.callback(widget.id, value);
          });
        },
      ),
    ]);
  }
}

// Radio Question
class RadioQuestion extends StatefulWidget {
  final String id;
  final String text;
  final List options;
  final bool multipleAnswers;
  final double weight;
  final void Function(String id, dynamic data) callback;

  RadioQuestion({Key key,this.id, this.text, this.options, this.multipleAnswers, this.weight, this.callback}) : super(key: key);

  @override
  _RadioQuestionState createState() => _RadioQuestionState();
}
class _RadioQuestionState extends State<RadioQuestion> {
  String _selected;
  
  String getData() {
    return _selected.toString();
  }

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
            widget.callback(widget.id, value);
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

class DropdownQuestion extends StatefulWidget {
  final String id;
  final String text;
  final List options;
  final void Function(String id, dynamic data) callback;
  final double weight;

  DropdownQuestion({Key key, this.id, this.text, this.options, this.weight, this.callback}) : super(key: key);

  @override
  _DropdownQuestionState createState() => _DropdownQuestionState();
}

class _DropdownQuestionState extends State<DropdownQuestion> {
  String _value;

  String getData() {
    return _value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Create list options
    List<Widget> widgetsList = [];
    List<DropdownMenuItem<String>> optionsList = [];

    // Add QuestionTitle to list
    widgetsList.add(Text(widget.text));

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
            widget.callback(widget.id, value);
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
