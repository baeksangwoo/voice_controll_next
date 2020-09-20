import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_controll_next/data/incoming_phrases.dart';
import 'package:voice_controll_next/data/listen_status_color.dart';

class TextRecognizePage extends StatefulWidget {
  @override
  _TextRecognizePageState createState() => _TextRecognizePageState();
}

class _TextRecognizePageState extends State<TextRecognizePage> {
  SpeechToText speech = SpeechToText();

  bool initialized = false;
  ListenStatusColor _listenStatusColor = ListenStatusColor();
  IncomingPhrases _incomingPhrases = IncomingPhrases();
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  String _isListeningText = "";

  PageController _pageController = PageController();
  Duration _animationDuration = Duration(milliseconds: 400);
  Curve _animeCurve = Curves.easeIn;

  @override
  void initState() {
    // TODO: implement initState
    speech
        .initialize(
            onStatus: (status) {
              print("status - $status");
              bool statusInBool = status.contains('not');
              _listenStatusColor.setColor(!statusInBool);
            },
            onError: (errorNotification) {
              print("ErrorNotification - $errorNotification");
            },
            debugLogging: true)
        .then((value) {
      initialized = value;
    });
    listenAgainIfItStops();
    super.initState();
  }

  void startListen() async {
    if (speech.isListening) await speech.stop();

    print("StartListen");

    if (_currentLocaleId.isEmpty) {
      await setLocale();
    }
    speech
        .listen(
            onResult: (result) {
              String text = result.alternates.first.recognizedWords;
              //   result.alternates.map((e) => e.recognizedWords).join(" | ");
              _incomingPhrases.setPhrases(text);

              switch(_incomingPhrases.action){
                case PageNextActions.prev:
                  _pageController.previousPage(duration: _animationDuration, curve: _animeCurve);
                  _incomingPhrases.resetAction();
                  break;
                case PageNextActions.next:
                  _pageController.nextPage(duration: _animationDuration, curve: _animeCurve);
                  _incomingPhrases.resetAction();
                  break;
                case PageNextActions.idle:
                  break;
              }
            },
            listenFor: Duration(seconds: 15),
            localeId: _currentLocaleId)
        .then((value) => print('then'));
  }

  void listenAgainIfItStops() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (speech.isNotListening && initialized) {
        startListen();
      }
    });
  }

  Future setLocale() async {
    // if (_localeNames.isEmpty) {
    //   _localeNames = await speech.locales();
    //   setState(() {});
    // }

    if (initialized) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = "ko-KR";
      print(systemLocale.name + " " + systemLocale.localeId);
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: _incomingPhrases,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              
              Consumer<IncomingPhrases>(
                builder: (BuildContext context, IncomingPhrases value, Widget child){
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: PageView(
                      controller: _pageController,
                      children: List.generate(
                          Colors.accents.length,
                              (index) => Container(
                                // decoration: BoxDecoration(
                                //   border: Border.all(width: 10,color: Colors.black),
                                //   color: Colors.accents[index % Colors.accents.length],
                                // ),
                            color: Colors.accents[index % Colors.accents.length],
                          )),
                    ),
                  );
                },
              ),
              Expanded(child: _incomingPhrasesText()),
              DropdownButton(
                onChanged: (selectedVal) => _switchLang(selectedVal),
                value: _currentLocaleId,
                items: _localeNames
                    .map(
                      (localeName) => DropdownMenuItem(
                        value: localeName.localeId,
                        child: Text(localeName.name),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  ChangeNotifierProvider<ListenStatusColor> _listeningIndicator() {
    return ChangeNotifierProvider<ListenStatusColor>.value(
      value: _listenStatusColor,
      child: Consumer<ListenStatusColor>(
        builder: (BuildContext context, ListenStatusColor value, Widget child) {
          return CircleAvatar(
            radius: 100,
            backgroundColor: value.color,
          );
        },
      ),
    );
  }

  ChangeNotifierProvider<ListenStatusColor> _listeningIndicator2() {
    return ChangeNotifierProvider<ListenStatusColor>.value(
      value: _listenStatusColor,
      child: Consumer<ListenStatusColor>(
        builder: (BuildContext context, ListenStatusColor value, Widget child) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: value.color,
            child: Center(
              child: Text(
                value.color == Colors.redAccent
                    ? "I'm Not listening..."
                    : "I'm listening...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

   Widget _incomingPhrasesText() {
    return Consumer<IncomingPhrases>(
      builder: (BuildContext context, IncomingPhrases value, Widget child) {
        return Text(value.phrases);
      },
    );
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
