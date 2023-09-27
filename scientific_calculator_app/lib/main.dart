//

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:async';

void main() {
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScientificCalculator()
    );
  }
}

class ScientificCalculator extends StatefulWidget {
  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  double screenWidth = 0;
  double screenHeight = 0;
  static double biggerFontSize = 55;
  static double smallerFontSize = 30;
  static String changeToDegree = 'DEG';
  static String changeToRadian = 'RAD';
  var question = '0';
  var answer = '0';
  var storedAnswer = 'nothing';
  bool equalsJustPressed = false;
  String radianOrDegree = changeToRadian;
  List<String> popMenuOptions = <String>['Report'];
  ScrollController questionFieldScrollController = ScrollController();
  ScrollController keypadFieldScrollController = ScrollController();
  double questionBarScale = 1;
  double questionBarOpacity = 1;
  double topContainer = 0;

  double questionFontSize() {
    if (equalsJustPressed) return smallerFontSize;
    return biggerFontSize;
  }

  double answerFontSize() {
    if (equalsJustPressed) return biggerFontSize;
    return smallerFontSize;
  }

  void _scrollToEnd() {
    questionFieldScrollController.animateTo(questionFieldScrollController.position.maxScrollExtent + 33,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /*void _scrollToBottom() {
    keypadFieldScrollController.animateTo(
        questionFieldScrollController.position.viewportDimension,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut
    );
  }*/
  String currentRadOrDeg() {
    if (radianOrDegree == changeToRadian) {
      return changeToDegree;
    } else {
      return changeToRadian;
    }
  }

  void initState() {
    super.initState();

    keypadFieldScrollController.addListener(() {
      double value = keypadFieldScrollController.offset / (screenWidth);
      setState(() {
        topContainer = value;
      });
    });
  }

  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    if (topContainer > 0) {
      questionBarScale = 1 + .15 - topContainer;
      if (questionBarScale < 0) {
        questionBarScale = 0;
      } else if (questionBarScale > 0.75) {
        questionBarScale = 1;
      }
      questionBarOpacity = questionBarScale;
    }

    if (questionBarOpacity > 0.75) {
      questionBarOpacity = 1;
    }
    if (questionBarOpacity < 0.40) {
      questionBarOpacity = 0;
    }

    return MaterialApp(
        theme: ThemeData(fontFamily: 'RobotMonoImportedFont'),
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text("Scientific Calculator"),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: popMenuPressAction,
                offset: Offset(0, 75),
                itemBuilder: (BuildContext context) {
                  return popMenuOptions.map((String choice) {
                    return PopupMenuItem<String>(value: choice, child: Text(choice));
                  }).toList();
                },
                shape: RoundedRectangleBorder(),
              )
            ],
          ),
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, stops: [
                0.1,
                0.2,
                0.3,
                0.4,
                0.5,
                0.6,
                0.7
              ], colors: [
                Color(0xff667de9),
                Color(0xff6876df),
                Color(0xff6b6dd4),
                Color(0xff6e64c6),
                Color(0xff6460c0),
                Color(0xff7356b4),
                Color(0xff764BA5)
              ])),
              child: Column(children: <Widget>[
                Expanded(
                  flex: 13,
                  child: Container(),
                ), // Empty to make appbar transparent
                Expanded(
                    flex: 33,
                    child: Container(
                        child: Column(
                      children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.maxFinite,
                                child: Text(
                                  currentRadOrDeg(),
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        Expanded(
                            flex: 7,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: SingleChildScrollView(
                                    controller: questionFieldScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 250),
                                      child: Text(question),
                                      style: TextStyle(fontSize: questionFontSize(), color: Colors.white, fontFamily: 'RobotMonoImportedFont'),
                                    ),
                                  )),
                            )),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                                alignment: Alignment.centerRight,
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 250),
                                      child: Text(answer),
                                      style: TextStyle(fontSize: answerFontSize(), color: Colors.white, fontFamily: 'RobotMonoImportedFont'),
                                    ))),
                          ),
                        ),
                      ],
                    ))), // Text Fields
                Expanded(
                  flex: 65,
                  child: Padding(
                    padding: EdgeInsets.only(left: screenWidth / 110, bottom: screenWidth / 110),
                    child: SingleChildScrollView(
                        controller: keypadFieldScrollController,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 2 * screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Opacity(
                                opacity: questionBarOpacity,
                                child: Transform(
                                  transform: Matrix4.identity()..scale(questionBarScale, questionBarScale),
                                  alignment: Alignment.center,
                                  child: Align(
                                    widthFactor: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: screenWidth / 110),
                                      child: SizedBox(
                                        height: screenHeight * .585586,
                                        width: screenWidth - screenWidth / 55,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(screenWidth / 11),
                                                topLeft: Radius.circular(screenWidth / 11),
                                                topRight: Radius.circular(screenWidth / 11),
                                                bottomRight: Radius.circular(screenWidth / 11)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 75,
                                                child: Container(
                                                    child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 20,
                                                      child: Row(
                                                        children: <Widget>[
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            'e',
                                                            '',
                                                          ),
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            'π',
                                                            '',
                                                          ),
                                                          inputButtons(Colors.transparent, Colors.redAccent, '⌫', '')
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 20,
                                                      child: Row(children: <Widget>[
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '1',
                                                          '',
                                                        ),
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '2',
                                                          '',
                                                        ),
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '3',
                                                          '',
                                                        ),
                                                      ]),
                                                    ),
                                                    Expanded(
                                                      flex: 20,
                                                      child: Row(children: <Widget>[
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '4',
                                                          '',
                                                        ),
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '5',
                                                          '',
                                                        ),
                                                        numberButtons(
                                                          Colors.transparent,
                                                          Color(0xff3D3D3D),
                                                          '6',
                                                          '',
                                                        ),
                                                      ]),
                                                    ),
                                                    Expanded(
                                                      flex: 20,
                                                      child: Row(
                                                        children: <Widget>[
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            '7',
                                                            '',
                                                          ),
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            '8',
                                                            '',
                                                          ),
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            '9',
                                                            '',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 20,
                                                      child: Row(
                                                        children: <Widget>[
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            '0',
                                                            '',
                                                          ),
                                                          numberButtons(
                                                            Colors.transparent,
                                                            Color(0xff3D3D3D),
                                                            '.',
                                                            '',
                                                          ),
                                                          inputButtons(Colors.transparent, Colors.green, 'ANS', ''),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                              ),
                                              Expanded(
                                                flex: 25,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: screenWidth / 30, right: screenWidth / 30, left: screenWidth / 30, bottom: screenWidth / 17.5),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [
                                                          0.1,
                                                          0.2,
                                                          0.3,
                                                          0.4,
                                                          0.5,
                                                          0.6,
                                                          0.7
                                                        ], colors: [
                                                          Color(0xff4e54c8),
                                                          Color(0xff585ED0),
                                                          Color(0xff646AD9),
                                                          Color(0xff6F74E2),
                                                          Color(0xff797EEA),
                                                          Color(0xff8489F3),
                                                          Color(0xff8f94fb)
                                                        ]),
                                                        borderRadius: BorderRadius.all(Radius.circular(screenWidth / 11))),
                                                    child: Column(
                                                      children: <Widget>[
                                                        operatorButtons(Colors.transparent, Colors.white, '÷', ''),
                                                        operatorButtons(Colors.transparent, Colors.white, '×', ''),
                                                        operatorButtons(Colors.transparent, Colors.white, '-', ''),
                                                        operatorButtons(Colors.transparent, Colors.white, '+', ''),
                                                        operatorButtons(Colors.transparent, Colors.white, '=', ''),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                  widthFactor: 0.95,
                                  child: SizedBox(
                                      height: screenHeight * 0.6,
                                      width: screenWidth - screenWidth / 110,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.only(bottomLeft: Radius.circular(screenWidth / 11), topLeft: Radius.circular(screenWidth / 11)),
                                          ),
                                          child: Row(children: <Widget>[
                                            Expanded(
                                              flex: 19,
                                              child: Column(
                                                children: <Widget>[
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'sin', 'asin'),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'x²', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '√', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '(', ''),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 19,
                                              child: Column(
                                                children: <Widget>[
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'cos', 'acos'),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'x³', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '∛', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), ')', ''),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 19,
                                              child: Column(
                                                children: <Widget>[
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'tan', 'atan'),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '^', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'ln', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), 'log', ''),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 19,
                                              child: Column(
                                                children: <Widget>[
                                                  radDegButton(Colors.transparent, Colors.white),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '!', ''),
                                                  operatorButtons(Colors.transparent, Color(0xff3D3D3D), '%', ''),
                                                  operatorButtons(
                                                    Colors.transparent,
                                                    Color(0xff3D3D3D),
                                                    'mod',
                                                    '',
                                                  ),
                                                ],
                                              ),
                                            )
                                          ])))),
                            ],
                          ),
                        )),
                  ),
                ) // Buttons
              ])),
        ));
  }

  Widget numberButtons(Color buttonColor, Color textColor, String text, String subText) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(screenWidth / 150),
        child: MaterialButton(
            color: buttonColor,
            shape: CircleBorder(),
            minWidth: screenWidth / 4,
            height: screenWidth / 4,
            elevation: 0,
            onPressed: () {
              numberButtonPressAction(text);
              equalsJustPressed = false;
            },
            child: Text(
              '' + text,
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth / 11,
              ),
              textAlign: TextAlign.center,
            )),
      ),
    );
  }
  numberButtonPressAction(String enterText) {
    if (equalsJustPressed == true) {
      question = '0';
      answer = '0';
      equalsJustPressed = false;
    }
    if (question == '0') {
      setState(() {
        question = enterText;
      });
    } else {
      setState(() {
        if (question.substring(question.length - 1) == 'e' ||
            question.substring(question.length - 1) == ')' ||
            question.substring(question.length - 1) == '!' ||
            question.substring(question.length - 1) == 'π') {
          question += '×' + enterText;
        } else if (enterText == 'e' || enterText == 'π') {
          String lastText = question.substring(question.length - 1);
          if (double.tryParse(lastText) != null || lastText == 'π' || lastText == ')') {
            question += '×' + enterText;
          } else {
            question += enterText;
          }
        } else {
          question += enterText;
        }
        _scrollToEnd();
      });
    }
  }

  Widget operatorButtons(Color buttonColor, Color textColor, String text, String subText) {
    if (subText.isEmpty) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(screenWidth / 150),
          child: MaterialButton(
            elevation: 0,
            shape: CircleBorder(),
            minWidth: screenWidth / 4,
            height: screenWidth / 4,
            child: Text(
              '' + text,
              style: TextStyle(color: textColor, fontSize: screenWidth / 13),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              if (text == '=') {
                equalsJustPressed = true;
                answerButtonPressAction();
              } else {
                operatorButtonPressAction(text);
                equalsJustPressed = false;
              }
            },
            color: buttonColor,
            splashColor: Colors.transparent,
          ),
        ),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(screenWidth / 150),
          child: MaterialButton(
            elevation: 0,
            shape: CircleBorder(),
            minWidth: screenWidth / 4,
            height: screenWidth / 4,
            onPressed: () {
              operatorButtonPressAction(text);
              equalsJustPressed = false;
            },
            onLongPress: () {
              operatorButtonPressAction(subText);
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '' + text,
                    style: TextStyle(color: textColor, fontSize: screenWidth / 13),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '' + subText,
                    style: TextStyle(color: Color(0xff6B6DD4), fontSize: screenWidth / 22),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            color: buttonColor,
            splashColor: Colors.transparent,
          ),
        ),
      );
    }
  }
  operatorButtonPressAction(String enterText) {
    if (equalsJustPressed == true) {
      if (storedAnswer.compareTo('nothing') != 0) {
        question = storedAnswer;
      } else {
        question = '0';
        answer = '0';
        equalsJustPressed = false;
      }
    }
    if (question == '0') {
      setState(() {
        if (enterText == 'cos' ||
            enterText == 'acos' ||
            enterText == 'sin' ||
            enterText == 'asin' ||
            enterText == 'tan' ||
            enterText == 'atan' ||
            enterText == 'log' ||
            enterText == 'ln' ||
            enterText == '√' ||
            enterText == '∛' ||
            enterText == 'mod') {
          question = enterText + '(';
        } else if (enterText == '+')
          question = '0';
        else if (enterText == '÷')
          question = '0';
        else if (enterText == '×')
          question = '0';
        else if (enterText == 'x²')
          question = '0';
        else if (enterText == 'x³')
          question = '0';
        else if (enterText == ')')
          question = '0';
        else if (enterText == '!')
          question += enterText;
        else
          question = enterText;

        _scrollToEnd();
      });
    } else {
      setState(() {
        if (enterText == 'cos' ||
            enterText == 'acos' ||
            enterText == 'sin' ||
            enterText == 'asin' ||
            enterText == 'tan' ||
            enterText == 'atan' ||
            enterText == 'log' ||
            enterText == 'ln' ||
            enterText == '√' ||
            enterText == '∛' ||
            enterText == 'mod') {
          if (enterText != 'mod') {
            String lastText = question.substring(question.length - 1);
            if (double.tryParse(lastText) != null || lastText == 'π' || lastText == ')') {
              question += '×' + enterText + '(';
            } else {
              question += enterText + '(';
            }
          } else {
            question += enterText + '(';
          }
        } else if (enterText == '(') {
          String lastText = question.substring(question.length - 1);
          if (double.tryParse(lastText) != null || lastText == 'π' || lastText == ')') {
            question += '×' + enterText;
          } else
            question += enterText;
        } else if (enterText == '!') {
          String lastText = question.substring(question.length - 1);
          if (lastText == '(' || lastText == 'e') {
          } else {
            question += enterText;
          }
        } else if (enterText == 'x²')
          question += '^(2)';
        else if (enterText == 'x³')
          question += '^(3)';
        else {
          if (question.endsWith('(') && (enterText.endsWith('+') || enterText.endsWith('÷') || enterText.endsWith('×'))) {
          } else if (question.endsWith('+') || question.endsWith('÷') || question.endsWith('×') || question.endsWith('-')) {
            question = question.substring(0, question.length - 1) + "" + enterText;
          } else {
            question += enterText;
          }
        }
        _scrollToEnd();
      });
    }
  }
  answerButtonPressAction() {
    int numOfCompleteParentheses = 0;
    String enteredQuestion = question;
    enteredQuestion = enteredQuestion.replaceAll('÷', '/');
    enteredQuestion = enteredQuestion.replaceAll('×', '*');
    enteredQuestion = enteredQuestion.replaceAll('asin', 'arcsin');
    enteredQuestion = enteredQuestion.replaceAll('acos', 'arccos');
    enteredQuestion = enteredQuestion.replaceAll('atan', 'arctan');
    enteredQuestion = enteredQuestion.replaceAll('e', 'e^1');
    enteredQuestion = enteredQuestion.replaceAll('π', '3.14159265358979323846');
    enteredQuestion = enteredQuestion.replaceAll('log(', 'log(10,');
    enteredQuestion = enteredQuestion.replaceAll('√(', 'sqrt(');
    enteredQuestion = enteredQuestion.replaceAll('∛(', 'nrt(3,');
    enteredQuestion = enteredQuestion.replaceAll('%', '/100');
    enteredQuestion = enteredQuestion.replaceAll('mod', '%');
    if (enteredQuestion.contains('E')) {
      enteredQuestion = enteredQuestion.replaceAll('E+', '*10^(');
      enteredQuestion = enteredQuestion.replaceAll('E', '*10^(');
    } //Make sure 'E' is converted to 'to the power of 10'

    for (int i = 0; i < enteredQuestion.length; i++) {
      if (enteredQuestion[i].endsWith('(')) numOfCompleteParentheses++;
      if (enteredQuestion[i].endsWith(')')) numOfCompleteParentheses--;
    }
    if (numOfCompleteParentheses > 0) {
      for (int i = 0; i < numOfCompleteParentheses; i++) {
        enteredQuestion += ')';
      }
    }

    try {
      //Solves the trig part before moving on
      if (currentRadOrDeg() == 'DEG') if (enteredQuestion.contains('sin') ||
          enteredQuestion.contains('cos') ||
          enteredQuestion.contains('tan') ||
          enteredQuestion.contains('asin') ||
          enteredQuestion.contains('acos') ||
          enteredQuestion.contains('atan')) enteredQuestion = trigValueCalculator(enteredQuestion);

      //Main Calculation Part if their is a factorial involved
      if (enteredQuestion.contains('!')) {
        for (int i = 0; i < enteredQuestion.length; i++) {
          if (enteredQuestion[i] == '!') {
            String lastText = enteredQuestion[i - 1];
            if (lastText == ')') {
              int openBracketIndex = -1;
              for (int k = i - 1; k >= 0; k--) {
                String previousText = enteredQuestion[k];
                if (previousText == '(') {
                  openBracketIndex = k;
                  break;
                }
              }
              if (openBracketIndex == -1) {
                throw 'error';
              } else {
                Parser p = Parser();
                Expression exp = p.parse(enteredQuestion.substring(openBracketIndex + 1, i - 1));
                ContextModel cm = ContextModel();
                double eval = exp.evaluate(EvaluationType.REAL, cm);
                double Factorial = factorial(eval);

                String bfr = enteredQuestion.substring(0, openBracketIndex);
                String factorialPart = Factorial.toString();
                if (factorialPart.contains('e')) {
                  int i = factorialPart.indexOf('e');
                  factorialPart = factorialPart.substring(0, i) + '*10^' + factorialPart.substring(i + 2, factorialPart.length);
                }
                String aft = enteredQuestion.substring(i + 1, enteredQuestion.length);
                enteredQuestion = bfr + factorialPart + aft;
              }
            } else if (double.tryParse(lastText) != null || lastText == 'π' || lastText == '.') {
              if (lastText == '.' && i - 2 > 0) {
                lastText = enteredQuestion[i - 2];
              }
              String numBefore = '';
              int lastIndex = 0;
              for (int j = i - 1; j >= 0; j--) {
                String previousText = enteredQuestion[j];
                if (double.tryParse(previousText) != null || previousText == 'π' || previousText == '.') {
                  numBefore += enteredQuestion[j];
                } else {
                  lastIndex = j;
                  break;
                }
              }
              double factorialNum = double.parse((numBefore.split('').reversed.join()));
              double Factorial = factorial(factorialNum);
              if (lastIndex == 0) lastIndex--;

              String bfr = enteredQuestion.substring(0, lastIndex + 1);
              String factorialPart = Factorial.toString();
              if (factorialPart.contains('e')) {
                int i = factorialPart.indexOf('e');
                factorialPart = factorialPart.substring(0, i) + '*10^' + factorialPart.substring(i + 2, factorialPart.length);
              }
              String aft = enteredQuestion.substring(i + 1, enteredQuestion.length);
              enteredQuestion = bfr + factorialPart + aft;
            }
          }
        } //Factorial Calculations
      }

      //Calculates the problem using dart.math import
      Parser p = Parser();
      Expression exp = p.parse(enteredQuestion);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        answer = num.parse(eval.toStringAsFixed(6)).toString();
        if (answer.contains('e')) {
          int i = answer.indexOf('e');
          answer = answer.substring(0, i) + 'E' + answer.substring(i + 1, answer.length);
        }
        if (answer.endsWith('Infinity')) {
        } else {
          storedAnswer = answer;
        }
      });
    } catch (e) {
      equalsJustPressed = false;
      setState(() {
        answer = 'ERROR';
      });
    }
  }

  Widget inputButtons(Color buttonColor, Color textColor, String text, String subText) {
    if (text.endsWith('ANS')) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(screenWidth / 150),
          child: MaterialButton(
            elevation: 0,
            shape: CircleBorder(),
            minWidth: double.maxFinite,
            height: double.maxFinite,
            onPressed: () {
              inputButtonPressAction(text);
            },
            child: Text(
              '' + text,
              style: TextStyle(color: textColor, fontSize: screenWidth / 13),
              textAlign: TextAlign.center,
            ),
            color: buttonColor,
            splashColor: buttonColor,
          ),
        ),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(screenWidth / 150),
          child: MaterialButton(
            elevation: 0,
            shape: CircleBorder(),
            minWidth: double.maxFinite,
            height: double.maxFinite,
            onPressed: () {
              inputButtonPressAction(text);
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              inputButtonPressAction('CLEAR');
            },
            child: Text(
              '' + text,
              style: TextStyle(color: textColor, fontSize: screenWidth / 13),
              textAlign: TextAlign.center,
            ),
            color: buttonColor,
            splashColor: buttonColor,
          ),
        ),
      );
    }
  }
  inputButtonPressAction(String enterText) {
    if (enterText == 'ANS') {
      setState(() {
        if (storedAnswer != 'nothing') {
          if (equalsJustPressed == true) {
            question = '0';
            answer = '0';
            equalsJustPressed = false;
          }
          if (question == '0') {
            question = storedAnswer;
          } else {
            String lastText = question.substring(question.length - 1);
            if (double.tryParse(lastText) != null ||
                question.substring(question.length - 1) == 'e' ||
                question.substring(question.length - 1) == ')' ||
                question.substring(question.length - 1) == '!' ||
                question.substring(question.length - 1) == 'π')
              question += '×' + storedAnswer;
            else
              question += storedAnswer;
          }
        }
        _scrollToEnd();
      });
    }
    else if (enterText == 'CLEAR') {
      equalsJustPressed = false;
      setState(() {
        question = '0';
        answer = '0';
        _scrollToEnd();
      });
    } else {
      setState(() {
        equalsJustPressed = false;
        if (question == '') {
          question = '0';
        } else if (question != '0') {
          question = question.substring(0, question.length - 1);
          if (question == '') {
            question = '0';
          }
        }
        _scrollToEnd();
      });
    }
  }

  Widget radDegButton(Color buttonColor, Color textColor) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(screenWidth / 150),
            child: MaterialButton(
              color: Color(0xff6E64C6),
              shape: CircleBorder(),
              //minWidth: screenWidth / 4,
              //height: screenWidth / 6,
              elevation: 0,
              onPressed: () {
                setState(() {
                  if (radianOrDegree == changeToDegree)
                    radianOrDegree = changeToRadian;
                  else
                    radianOrDegree = changeToDegree;
                });
              },
              child: Text(
                radianOrDegree,
                style: TextStyle(color: textColor, fontSize:  screenWidth / 13),
                textAlign: TextAlign.center,
              ))));
  }
  String trigValueCalculator(String enteredQuestion) {
    for (int i = 0; i < enteredQuestion.length; i++) {
      int currentTrigFunctionIndex = -1;
      String currentTrigFunction = '';
      String bracketPart = '';
      int closeBracketindex = -1;

      //finds the current trig function
      try {
        if (enteredQuestion.substring(i, i + 3) == 'arc' ||
            enteredQuestion.substring(i, i + 3) == 'sin' ||
            enteredQuestion.substring(i, i + 3) == 'cos' ||
            enteredQuestion.substring(i, i + 3) == 'tan') {
          currentTrigFunctionIndex = i;
          if (enteredQuestion.substring(i, i + 3) == 'arc') {
            if (enteredQuestion[i + 3] == 's') {
              currentTrigFunction = 'arcsin';
            } else if (enteredQuestion[i + 3] == 'c') {
              currentTrigFunction = 'arccos';
            } else if (enteredQuestion[i + 3] == 't') {
              currentTrigFunction = 'arctan';
            }
          } else if (enteredQuestion[i] == 's') {
            currentTrigFunction = 'sin';
          } else if (enteredQuestion[i] == 'c') {
            currentTrigFunction = 'cos';
          } else if (enteredQuestion[i] == 't') {
            currentTrigFunction = 'tan';
          }
        }
      } catch (e) {
        break;
      }
      //takes out the string form inside the paranthesis
      if (currentTrigFunction == 'sin' || currentTrigFunction == 'cos' || currentTrigFunction == 'tan') {
        int openBracketcounter = 0;
        int closeBracketcounter = 0;
        for (int j = currentTrigFunctionIndex + 3; j < enteredQuestion.length; j++) {
          if (enteredQuestion[j] == '(') {
            openBracketcounter++;
          }
          if (enteredQuestion[j] == ')') {
            closeBracketcounter++;
          }
          if (openBracketcounter - closeBracketcounter == 0) {
            bracketPart = enteredQuestion.substring(currentTrigFunctionIndex + 4, j);
            closeBracketindex = j;
            break;
          }
        }
      } else if (currentTrigFunction == 'arcsin' || currentTrigFunction == 'arccos' || currentTrigFunction == 'arctan') {
        int openBracketcounter = 0;
        int closeBracketcounter = 0;
        for (int j = currentTrigFunctionIndex + 6; j < enteredQuestion.length; j++) {
          if (enteredQuestion[j] == '(') {
            openBracketcounter++;
          }
          if (enteredQuestion[j] == ')') {
            closeBracketcounter++;
          }
          if (openBracketcounter - closeBracketcounter == 0) {
            bracketPart = enteredQuestion.substring(currentTrigFunctionIndex + 7, j);
            closeBracketindex = j;
            break;
          }
        }
      }

      //finds other trig functions within the this trig function (inside the bracket)
      if (bracketPart.contains('arc') || bracketPart.contains('sin') || bracketPart.contains('cos') || bracketPart.contains('tan')) {
        bracketPart = trigValueCalculator(bracketPart);
      }

      //if no trig function is found at this index do nothing
      if (currentTrigFunctionIndex == -1) {
      }
      //else do the necessary calculations
      else {
        //solve the bracket
        double evalutedTrigPart = 0;
        Parser p = Parser();
        Expression exp = p.parse(bracketPart);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);

        if (currentTrigFunction == 'sin' || currentTrigFunction == 'cos' || currentTrigFunction == 'tan') {
          if (currentTrigFunction == 'sin') {
            if ((eval / 90) % 2 == 0) {
              evalutedTrigPart = 0;
            } else {
              evalutedTrigPart = Math.sin(eval * Math.pi / 180);
            }
          } else if (currentTrigFunction == 'cos') {
            if ((eval / 90) % 2 == 1) {
              evalutedTrigPart = 0;
            } else {
              evalutedTrigPart = Math.cos(eval * Math.pi / 180);
            }
          } else if (currentTrigFunction == 'tan') {
            if ((eval / 90) % 2 == 1) {
              throw ArgumentError;
            }
            evalutedTrigPart = Math.tan(eval * Math.pi / 180);
          }
        } else if (currentTrigFunction == 'arcsin' || currentTrigFunction == 'arccos' || currentTrigFunction == 'arctan') {
          if (currentTrigFunction == 'arcsin') {
            if (eval > 1 || eval < -1) {
              throw ArgumentError;
            } else {
              evalutedTrigPart = Math.asin(eval) * 180 / Math.pi;
            }
          } else if (currentTrigFunction == 'arccos') {
            if (eval > 1 || eval < -1) {
              throw ArgumentError;
            } else {
              evalutedTrigPart = Math.acos(eval) * 180 / Math.pi;
            }
          } else if (currentTrigFunction == 'arctan') {
            if (eval > 1 || eval < -1) {
              throw ArgumentError;
            } else {
              evalutedTrigPart = Math.atan(eval) * 180 / Math.pi;
            }
          }
        }

        evalutedTrigPart = double.parse(evalutedTrigPart.toStringAsFixed(10));
        String bfr = enteredQuestion.substring(0, currentTrigFunctionIndex);
        String trigPart = evalutedTrigPart.toString();
        String aft = enteredQuestion.substring(closeBracketindex + 1, enteredQuestion.length);
        enteredQuestion = bfr + trigPart + aft;
      }
    }
    return enteredQuestion;
  }

  double factorial(double value) {
    bool isInteger(value) => (value % 1) == 0;
    if (value == 0)
      return 1;
    else if (isInteger(value)) {
      double d = value * Math.exp(logGamma(value));
      return double.parse(d.toStringAsFixed(1));
    } else {
      return value * Math.exp(logGamma(value));
    }
  }
  double logGamma(double x) {
    double tmp = (x - 0.5) * Math.log(x + 4.5) - (x + 4.5);
    double ser =
        1.0 + 76.18009173 / (x + 0) - 86.50532033 / (x + 1) + 24.01409822 / (x + 2) - 1.231739516 / (x + 3) + 0.00120858003 / (x + 4) - 0.00000536382 / (x + 5);
    return tmp + Math.log(ser * Math.sqrt(2 * Math.pi));
  }

  popMenuPressAction(String choice) {
    if (choice == 'Report') {
      _launchInBrowser('https://divyanshusingh2903.wixsite.com/scientific-calc');
    }
  }
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'header_key': 'header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
