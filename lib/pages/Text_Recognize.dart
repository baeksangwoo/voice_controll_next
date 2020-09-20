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
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _listeningIndicator(),
            _listeningIndicator2(),
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

  ChangeNotifierProvider<IncomingPhrases> _incomingPhrasesText() {
    return ChangeNotifierProvider<IncomingPhrases>.value(
      value: _incomingPhrases,
      child: Consumer<IncomingPhrases>(
        builder: (BuildContext context, IncomingPhrases value, Widget child) {
          return Text(value.phrases);
        },
      ),
    );
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
