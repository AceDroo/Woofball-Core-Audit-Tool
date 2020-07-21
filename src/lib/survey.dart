import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'results.dart';

class Survey extends StatefulWidget {
  Survey({Key key, this.page, this.editMode}) : super(key: key);
  final int page;
  final bool editMode;

  _SurveyState createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  bool tIntVal = false;
  bool fWayVal = false;
  bool otherVal = false;
  bool noneVal = false;
  String otherText = "";
  double _restVal = 0;
  double _coffeeVal = 0;
  double _libraryVal = 0;
  bool currentUnset = true;
  static int currentPage = 0;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    if (currentUnset) {
      currentPage = widget.page;
      currentUnset = false;
    }
    _pageController = PageController(initialPage: currentPage);
  }

  Widget checkbox(String title, bool boolValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title),
        Checkbox(
          value: boolValue,
          onChanged: (bool value) {
            setState(() {
              switch (title) {
                case "T-Intersection":
                  tIntVal = value;
                  break;
                case "4 Way":
                  fWayVal = value;
                  break;
                case "Other":
                  otherVal = value;
                  break;
                case "No Intersection":
                  noneVal = value;
                  break;
              }
            });
          },
        )
      ],
    );
  }

  Widget slider(String title, double max, int div, double val) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title),
          Slider(
              value: val,
              min: 0,
              max: max,
              divisions: div,
              label: val.round().toString(),
              onChanged: (value) {
                setState(() {
                  switch (title) {
                    case "Restaurants":
                      _restVal = value;
                      break;
                    case "Coffee Shops":
                      _coffeeVal = value;
                      break;
                    case "Libraries/Bookshops":
                      _libraryVal = value;
                      break;
                  }
                });
              }
          )
        ]);
  }

  Widget pageTitle(String title, String help) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title + "   ",
              style: TextStyle(fontSize: 16)),
          InkWell(
              child: new Text('?', style: TextStyle(color: Colors.blue, fontSize: 24, decoration: TextDecoration.underline)),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => new AlertDialog(
                        title: Text(title),
                        content: Text(help)
                  )
                );
              })
        ]
    );
}

  getPage(int index) {
    //return _pages[index];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      Container(
          child: ListView(
            children: <Widget>[
              Center(
                  child: Column(
                      children: <Widget>[
                        Text("\nIntersection", style: TextStyle(fontSize: 26)),
                        pageTitle("1. Type of Intersection",
                            "Enter the type of intersection present in this segment.\n\n1. T-Intersection - Two roads meet (sometimes at right angles) and one road ends.\n2. 4 Way - 4 roads connect together at a central point.\n3. Other - An intersection not listed\n4. No intersection - No intersection present"),
                        Text("Select all options that apply",
                            style: TextStyle(fontSize: 16)),
                        CheckboxListTile(
                          title: Text('T-Intersection'),
                          value: tIntVal,
                          onChanged: (value) {
                            setState(() {
                              tIntVal = value;
                              if (value) {
                                otherVal = false;
                                fWayVal = false;
                                noneVal = false;
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('4 Way'),
                          value: fWayVal,
                          onChanged: (value) {
                            setState(() {
                              fWayVal = value;
                              if (value) {
                                otherVal = false;
                                tIntVal = false;
                                noneVal = false;
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Other'),
                          value: otherVal,
                          onChanged: (value) {
                            setState(() {
                              otherVal = value;
                              if (value) {
                                tIntVal = false;
                                fWayVal = false;
                                noneVal = false;
                              }
                            });
                          },
                        ),
                        if (otherVal) Container(
                            margin: EdgeInsets.all(12),
                            height: 5 * 24.0,
                            child: TextField(
                              maxLines: 5,

                              onChanged: (text) {
                                otherText = text;
                              },
                              style: TextStyle(
                                  fontSize: 16.0,
                                  height: 2.0,
                                  color: Colors.black
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            )
                        ),
                        CheckboxListTile(
                          title: Text('No intersection'),
                          value: noneVal,
                          onChanged: (value) {
                            setState(() {
                              noneVal = value;
                              if (value) {
                                tIntVal = false;
                                fWayVal = false;
                                otherVal = false;
                              }
                            });
                          },
                        ),
                      ]
                  )
              )
            ],
          )
      ),
      Container(
          child: ListView(
            children: <Widget>[
              Center(
                  child: Column(
                      children: <Widget>[
                        Text("\nPhoto", style: TextStyle(fontSize: 26)),
                        pageTitle("2. Take or upload a photo", "Upload one or more photos of the segment using the device's camera"),
                        ButtonBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton.icon(onPressed: () {
                                print('yay');
                              },
                                  icon: Icon(Icons.add_a_photo),
                                  label: Text('Take a photo')),
                              RaisedButton.icon(onPressed: () {
                                print('yay');
                              },
                                  icon: Icon(Icons.add_photo_alternate),
                                  label: Text('Upload a photo')),
                            ]
                        )
                      ]
                  )
              )
            ],
          )
      ),
      Container(
          child: ListView(
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[

                    Text("\nLand Use", style: TextStyle(fontSize: 26)),
                    pageTitle("3. Number of gathering places on this segment", "Enter the number of gathering places found on this segment"),
                    slider("Restaurants", 10, 10, _restVal),
                    slider("Coffee Shops", 10, 10, _coffeeVal),
                    slider("Libraries/Bookshops", 10, 10, _libraryVal)
                  ],
                ),
              )
            ],
          )
      ),
    ];

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: InkWell(
                child: Column(
                  children: <Widget>[
                    Text('27 King St'),
                    Text('Tap to change location',
                        style: TextStyle(fontSize: 12))
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                })),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('1. Intersection (icon here)'),
                onTap: () {
                  _pageController.jumpToPage(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('2. Take a photo (icon here)'),
                onTap: () {
                  _pageController.jumpToPage(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('3. Land use (icon here)'),
                onTap: () {
                  _pageController.jumpToPage(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            if (index >= _pages.length) {
              return null;
            }
            //print(_pages.length);   <= USED FOR DEBUGGING
            //print(index);
            return _pages[index];
          },
          onPageChanged: (page) {
            setState(() {
              currentPage = page;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                heroTag: 'prevFAB',
                onPressed: () {
                  _pageController.animateToPage(
                      _pageController.page.toInt() - 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: Icon(Icons.navigate_before),
              ),
              if (currentPage < _pages.length - 1 && !widget.editMode)
                FloatingActionButton(
                  heroTag: 'nextFAB',
                  onPressed: () {
                    _pageController.animateToPage(
                        _pageController.page.toInt() + 1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  child: Icon(Icons.navigate_next),
                ),
              if (currentPage >= _pages.length - 1 || widget.editMode)
                FloatingActionButton(
                  heroTag: 'submitFAB',
                  onPressed: () {
                    _pageController.jumpToPage(0);
                    Navigator.pop(context); // Closes drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Results()), // Go to survey page
                    );
                  },
                  child: Icon(Icons.done),
                ),
            ],
          ),
        )
    );
  }
}